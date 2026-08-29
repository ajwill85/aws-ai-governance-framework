"""
Authentication API Endpoints
"""

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import settings
from app.core.security import (
    create_access_token,
    get_password_hash,
    verify_password,
)
from app.db import models
from app.db.session import get_db

router = APIRouter()


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str = ""
    company_name: str = "Demo Company"


def _authenticate_user(
    db: Session, email: str, password: str
) -> models.User | None:
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user or not user.is_active:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


@router.post("/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    """
    Authenticate with email (username field) + password and return a JWT.
    """
    user = _authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user.last_login = datetime.now(timezone.utc)
    db.commit()

    access_token = create_access_token(
        subject=str(user.id),
        extra_claims={"email": user.email, "role": user.role},
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role,
            "company_id": user.company_id,
        },
    }


@router.post("/logout")
async def logout(current_user: models.User = Depends(get_current_user)):
    """
    Logout endpoint (client discards the token; requires a valid session).
    """
    return {"message": "Logged out successfully", "user_id": current_user.id}


@router.get("/me")
async def get_me(current_user: models.User = Depends(get_current_user)):
    """Return the authenticated user."""
    return {
        "id": current_user.id,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "company_id": current_user.company_id,
        "role": current_user.role,
        "is_active": current_user.is_active,
    }


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(
    body: RegisterRequest,
    db: Session = Depends(get_db),
):
    """
    Create a company + admin user for local/demo bootstrap.
    Disabled outside development.
    """
    if settings.ENVIRONMENT.lower() not in {"development", "dev", "test"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Registration is disabled outside development",
        )

    existing = db.query(models.User).filter(models.User.email == body.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    slug = body.company_name.lower().replace(" ", "-")[:100] or "demo-company"
    company = db.query(models.Company).filter(models.Company.slug == slug).first()
    if not company:
        company = models.Company(name=body.company_name, slug=slug)
        db.add(company)
        db.flush()

    user = models.User(
        email=body.email,
        hashed_password=get_password_hash(body.password),
        full_name=body.full_name or body.email.split("@")[0],
        company_id=company.id,
        role="admin",
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "id": user.id,
        "email": user.email,
        "full_name": user.full_name,
        "company_id": user.company_id,
        "role": user.role,
    }
