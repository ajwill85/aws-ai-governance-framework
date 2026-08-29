"""
Application Configuration
"""

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List
import os
import secrets
import warnings


class Settings(BaseSettings):
    model_config = SettingsConfigDict(case_sensitive=True, env_file=".env")

    # Project Info
    PROJECT_NAME: str = "AWS AI Governance Platform"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"

    # API Settings
    API_V1_STR: str = "/api/v1"

    # Security
    SECRET_KEY: str = ""
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60  # 1 hour

    # Database
    DATABASE_URL: str = ""

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
    ]

    # AWS Settings
    AWS_REGION: str = "us-east-1"
    AWS_SCANNER_ROLE_NAME: str = "GRCGovernanceScanner"

    # Scanning
    MAX_CONCURRENT_SCANS: int = 5
    SCAN_TIMEOUT_MINUTES: int = 30

    # Pagination
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100

    @model_validator(mode="after")
    def ensure_secret_key(self) -> "Settings":
        env = (self.ENVIRONMENT or "development").lower()
        placeholder = {"", "your_secret_key_here", "changeme"}
        if self.SECRET_KEY.strip() not in placeholder:
            return self
        if env in {"production", "prod", "staging"}:
            raise ValueError(
                "SECRET_KEY must be set to a strong value when ENVIRONMENT="
                f"{env}. Generate one with: openssl rand -hex 32"
            )
        warnings.warn(
            "SECRET_KEY is unset; using an ephemeral development key. "
            "Set SECRET_KEY in .env for persistent sessions.",
            UserWarning,
            stacklevel=2,
        )
        self.SECRET_KEY = secrets.token_hex(32)
        return self


settings = Settings()
