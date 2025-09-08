# StudioManager Data Model Documentation

This document outlines the data model for the StudioManager application, which is managed using Core Data. The model is designed to be robust, scalable, and prevent data duplication by normalizing information into distinct entities.

## Core Entities

The data model is composed of the following entities:

### 1. `GearItem`

- **Purpose:** Represents a single, physical piece of equipment in the studio.
- **Attributes:**
  - `name`: The specific name of the gear (e.g., "WA-87 R2", "Pultec EQP-1A").
  - `notes`: Any freeform text or notes about this specific piece of gear.
- **Relationships:**
  - `manufacturer`: A **To-One** relationship to the `Manufacturer` who made the gear.
  - `gearType`: A **To-One** relationship to the `GearType` that categorizes the gear (e.g., "Microphone").
  - `controls`: A **To-Many** relationship to all the `GearControl`s available on this piece of gear.
  - `settings`: A **To-Many** relationship to all the `Setting`s that have ever been saved for this gear across all presets.

### 2. `Manufacturer`

- **Purpose:** Represents the company that manufactures a piece of gear. Storing this separately prevents typos and allows for easy filtering.
- **Attributes:**
  - `name`: The name of the company (e.g., "Warm Audio", "Neve", "Universal Audio").
- **Relationships:**
  - `gearItems`: A **To-Many** relationship linking to every `GearItem` made by this manufacturer.

### 3. `GearType`

- **Purpose:** Represents the category of a piece of gear. This allows for organizing gear by its function.
- **Attributes:**
  - `name`: The type of gear (e.g., "Microphone", "Preamp", "Compressor", "EQ").
- **Relationships:**
  - `gearItems`: A **To-Many** relationship linking to every `GearItem` of this type.

### 4. `Preset`

- **Purpose:** This is the core organizational entity. It represents a complete snapshot of settings for a specific purpose.
- **Attributes:**
  - `name`: The descriptive name of the preset (e.g., "Brock's Lead Vocals", "Bright Acoustic Guitar", "Kick In").
- **Relationships:**
  - `scenario`: A **To-One** relationship to the `Scenario` this preset belongs to (e.g., "Vocal Tracking").
  - `settings`: A **To-Many** relationship to the collection of individual `Setting`s that make up this preset.

### 5. `Scenario`

- **Purpose:** A high-level category for grouping presets. This allows for organizing presets by the situation they are used in.
- **Attributes:**
  - `name`: The name of the scenario (e.g., "Vocal Tracking", "Drum Miking", "Mix Bus").
- **Relationships:**
  - `presets`: A **To-Many** relationship linking to every `Preset` that falls under this scenario.

### 6. `Setting`

- **Purpose:** Represents a single knob, switch, or fader position for one piece of gear within a specific preset.
- **Attributes:**
  - `controlValue`: The actual value of the setting (e.g., "45dB", "80Hz", "Cardioid", "On").
- **Relationships:**
  - `preset`: A **To-One** relationship indicating which `Preset` this setting belongs to.
  - `gearItem`: A **To-One** relationship linking to the specific `GearItem` being adjusted.
  - `control`: A **To-One** relationship linking to the specific `GearControl` being set.

### 7. `GearControl`

- **Purpose:** Defines a single controllable parameter on a piece of gear. This avoids storing control names as simple strings.
- **Attributes:**
  - `name`: The name of the control (e.g., "Gain", "HPF", "Polar Pattern", "Attack").
- **Relationships:**
  - `gearItem`: A **To-One** relationship to the `GearItem` this control belongs to.
  - `controlType`: A **To-One** relationship to the `ControlType` that defines the UI for this control (e.g., "Knob").
  - `settings`: A **To-Many** relationship to all the `Setting`s that have ever been saved for this control.

### 8. `ControlType`

- **Purpose:** Defines the physical or logical type of a `GearControl`. This allows for displaying the correct UI (e.g., a rotary knob, a toggle switch).
- **Attributes:**
  - `name`: The name of the control type (e.g., "Knob", "Switch", "Fader", "Button").
- **Relationships:**
  - `controls`: A **To-Many** relationship to every `GearControl` of this type.

## How They Work Together: An Example

1.  You add a **`Manufacturer`** named "Warm Audio".
2.  You add a **`GearType`** called "Preamp".
3.  You create a new **`GearItem`** called "WA73-EQ". You link it to the "Warm Audio" `Manufacturer` and the "Preamp" `GearType`.
4.  For the "WA73-EQ", you create its **`GearControl`**s, such as "Gain" and "HPF". You assign them a **`ControlType`** like "Knob".
5.  You create a **`Scenario`** called "Vocal Tracking".
6.  You create a **`Preset`** called "Brock's Vocals" and link it to the "Vocal Tracking" `Scenario`.
7.  To build the preset, you create **`Setting`**s.
    - One `Setting` links to the "WA73-EQ" `GearItem` and its "Gain" `GearControl`, and you set its `controlValue` to "45dB".
    - Another `Setting` links to the same "WA73-EQ" and its "HPF" `GearControl`, and you set its `controlValue` to "80Hz".
8.  When you recall the "Brock's Vocals" `Preset`, the app fetches all its associated `Setting`s and displays them, showing you exactly how to set up your gear.
