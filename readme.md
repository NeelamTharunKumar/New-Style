# StyleDNA AI

> **The definitive AI-powered personal fashion operating system.**

StyleDNA AI is not another clothing recommendation app. It is a **wardrobe-native intelligence platform** that understands *your* clothes, *your* body, and *your* style — and generates outfits exclusively from what you already own.

---

## 🎯 Vision

Existing apps like **Essembl**, **Whering**, and **Acloset** focus on catalog matching or basic tagging. They treat your wardrobe as a passive list.

**StyleDNA AI** flips the model:

- Your wardrobe becomes the **source of truth**
- AI generates **thousands of outfit combinations** using only the clothes you own
- Every recommendation respects your personal **Style DNA** (skin tone, body type, fashion personality)
- Processing happens **on-device first** for maximum privacy and speed

This is the foundation of a true **personal fashion OS**.

---

## ✨ Core Differentiator: "Your Outfits"

This is the heart of the product.

Users upload photos of their actual clothing. The AI then intelligently combines those items into context-aware outfits:

- College outfits
- Office outfits
- Wedding outfits
- Date nights
- Travel packing lists

Each suggestion includes a clear explanation of **why** the combination works — based on color harmony, style consistency, occasion suitability, and the user’s personal Style DNA profile.

No more “what should I wear?” paralysis.

---

## 🧠 Technical Philosophy

We built StyleDNA AI with strict principles:

| Principle                    | Implementation                              |
|-----------------------------|---------------------------------------------|
| **On-Device First**         | MediaPipe, YOLO, CLIP run locally           |
| **Minimal LLM Usage**       | Only structured features sent to LLMs       |
| **Privacy by Design**       | Raw images never leave the device           |
| **Dependency Inversion**    | All ML services behind clean interfaces     |
| **Production Grade**        | Clean architecture, scalable, testable      |

This approach delivers:
- Blazing fast outfit generation (< 500ms)
- Extremely low operational cost
- Maximum user privacy

---

## 🏗️ Current Implementation

The repository contains a **complete, runnable foundation**.

### Flutter App (`flutter_app/`)
- Premium dark-mode UI
- 5 fully functional screens

### Backend (`backend/`)
- FastAPI with local graph engine

### Full Specification
See `StyleDNA_AI_Complete_Specification.md`

---

## 🚀 Getting Started

### Flutter App
```bash
cd flutter_app
flutter pub get
flutter run