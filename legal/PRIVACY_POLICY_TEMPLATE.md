# Drape AI Privacy Policy Template

_Last updated: TODO_

This is a template and should be reviewed by a qualified legal professional before launch.

## 1. Overview

Drape AI helps users organize wardrobe items and generate outfit recommendations from clothes they already own.

## 2. Privacy-first design

Raw wardrobe photos and selfies are designed to stay on the user's device by default. The backend is designed to process structured wardrobe/profile features such as item IDs, clothing category, color, fabric, style tags, occasion tags and weather/occasion context.

## 3. Information we process

Depending on user choices, we may process:

- account identifier
- structured style profile
- structured wardrobe item attributes
- local image reference strings
- generated outfit recommendations
- app diagnostics and request metadata

## 4. Photos and images

The app is designed so raw photos are not required by the backend or LLM. Local image references may be stored to help the app display images on the same device.

## 5. AI/LLM processing

When explanation AI is enabled, only structured features and candidate outfit metadata should be sent to the LLM. Raw images should not be sent to the LLM.

## 6. Data deletion/export

Users may request/export/delete structured account data. The backend supports data export and deletion endpoints for user profile and structured wardrobe items.

## 7. Security

Authentication tokens are stored using platform secure storage. Production backend deployments should use HTTPS, API authentication, and database access controls.

## 8. Contact

TODO: Add company/contact email.
