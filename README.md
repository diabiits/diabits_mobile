# Diabits Mobile App

Flutter Android app for low-stress collection of health data and manual inputs in the Diabits system.

## Purpose
Acts as the primary data source by combining automatic health metrics with manual inputs to support analysis of blood glucose level patterns.

- Collects data from Health Connect (glucose levels, sleep, heart rate, activity)
- Captures contextual inputs (medication, menstrual cycle)
- Syncs data to backend for storage and analysis

## Tech Stack
- Flutter (Dart)
- Health Connect
- REST API (Diabits API)

## Responsibilities
- Retrieve health data from connected sources
- Handle manual user input
- Sync data with backend API

## Key Concepts

### Automatic Data Collection
- Uses Health Connect
- Focus on objective, measurable data
- Runs daily synchronization with retry and backoff
- Minimizes manual effort

### Manual Input
- Adds contextual data not available through sensors
- Synced to backend immediately
- Full CRUD support

## Features
- Invite-based user registration and login
- Manual data entry
- Daily background data sync

## Notes
- Android only
- Designed to minimize user effort and cognitive load
- Part of a larger system with API and dashboard
