"""initial schema

Revision ID: 0001_initial_schema
Revises:
Create Date: 2026-05-31
"""
from __future__ import annotations

from alembic import op
import sqlalchemy as sa

revision = "0001_initial_schema"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "user_profiles",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("profile_json", sa.Text(), nullable=False),
        sa.PrimaryKeyConstraint("user_id"),
    )
    op.create_table(
        "wardrobe_items",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("item_id", sa.String(length=128), nullable=False),
        sa.Column("item_json", sa.Text(), nullable=False),
        sa.PrimaryKeyConstraint("user_id", "item_id"),
    )
    op.create_index("idx_wardrobe_items_user_id", "wardrobe_items", ["user_id"])


def downgrade() -> None:
    op.drop_index("idx_wardrobe_items_user_id", table_name="wardrobe_items")
    op.drop_table("wardrobe_items")
    op.drop_table("user_profiles")
