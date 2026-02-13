# Implementation Plan - Pixel-Perfect UI Refinement

## Goal
Align `HomeView` and `CalendarView` strictly with the provided React prototypes (`HomeView.tsx`, `CalendarView.tsx`) to achieve commercial-grade aesthetics.

## Prototype Analysis & Gaps

### 1. HomeView Refinement
- **Header**:
    - Prototype: `tracking-widest` for "DICTATION PAL". Text size `text-3xl` (approx 30sp) for greeting.
    - Current: 28sp. Letter spacing might need adjustment.
- **Hero Cards**:
    - Prototype: `rounded-[32px]`. Shadows are colored `shadow-indigo-500/30`.
    - Current: `BorderRadius.circular(32)` is correct, but shadows might need fine-tuning (using `BoxShadow` with color opacity).
- **Stats Grid**:
    - Prototype: `gap-4` (16px). Cards have `border-2`.
    - Current: Check spacing and border width.
- **Recent History**:
    - Prototype: Empty state has specific styling. History items have `rounded-[24px]`?

### 2. CalendarView Refinement
- **Header**:
    - Prototype: Sticky header with `backdrop-blur-sm` and `bg-slate-50/50`.
    - Current: `Container` with opacity, likely missing true blur.
- **Streak Card**:
    - Prototype: `rounded-[32px]`, `shadow-xl shadow-orange-500/20`. Inner circle `blur-3xl`.
    - Current: Basic gradient. Need to enhance the "glow" effect.
- **Calendar Grid**:
    - Prototype: `rounded-[32px]`.
    - Current: `PremiumCard` (usually rounded 20-24). Need to match 32px.

## Proposed Changes

### [Modify] `lib/ui/views/home/home_view.dart`
- **Header**: Increase font size of greeting to `30`, increase letter spacing of "DICTATION PAL" to `2.0`.
- **Hero Cards**: Ensure `BoxShadow` matches the specific gradient color with lower opacity (e.g. `violet600.withOpacity(0.3)`).
- **Stats Grid**: adjustments to `PremiumCard` to support `borderRadius: 24` or `32` explicitly if needed.

### [Modify] `lib/ui/views/calendar/calendar_view.dart`
- **Header**: Use `ClipRect` + `BackdropFilter` for the sticky header mechanism to ensure true blur effect over content.
- **Streak Card**: Add the "glow" blobs using `Positioned` + `Container` with `BoxShape.circle` and high `blurRadius` (e.g. 60-100).
- **Rewards**: Ensure horizontal list has proper `clipBehavior: Clip.none` so shadows don't get cut off.
- **Calendar Grid**: Match card border radius to `32`.

### [Modify] `lib/ui/widgets/premium_card.dart`
- Allow custom `borderRadius` property to support the larger 32px rounding used in hero sections.
