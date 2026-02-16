# FuelTrackr - App Description

## Overview

FuelTrackr is a comprehensive iOS mobile application designed for vehicle owners to track, monitor, and analyze their vehicle's fuel consumption, maintenance records, and mileage data. The app provides users with detailed insights into their driving habits, fuel costs, and vehicle maintenance needs.

## Core Functionality

### Vehicle Management
- **Vehicle Registration**: Users can register and manage their vehicles with details including:
  - Vehicle name
  - License plate number
  - Purchase date
  - Manufacturing date
  - Vehicle photos
  - Fuel type (gasoline, diesel, electric, hydrogen)
  - Purchase status tracking

### Fuel Usage Tracking
- **Fuel Entry Recording**: Users can log fuel refills with:
  - Fuel amount (liters, gallons, kWh for electric vehicles, or kg H₂ for hydrogen)
  - Cost per refill
  - Date and time of refill
  - Current mileage/odometer reading
  - Support for multiple fuel types

- **Partial Fill Detection**: Automatic detection and manual marking of partial fuel fills to ensure accurate consumption calculations

- **Fuel Consumption Analysis**: 
  - Automatic calculation of fuel consumption rates (L/100km or MPG)
  - Fuel consumption history with visual representations
  - Average fuel consumption over time periods
  - Fuel cost tracking and analysis

### Mileage Tracking
- **Odometer Recording**: Track vehicle mileage over time
- **Distance Calculations**: Automatic calculation of distance driven between fuel entries
- **Mileage History**: Historical mileage records with date tracking
- **Monthly Distance Tracking**: Calculate kilometers/miles driven per month

### Maintenance Management
- **Maintenance Records**: Log maintenance activities including:
  - Maintenance type (oil change, tire replacement, brake service, distribution belt, etc.)
  - Maintenance date
  - Cost
  - Notes and additional information
  - Free maintenance flagging

- **Maintenance Intervals**: Set default maintenance intervals for different service types
- **Maintenance History**: View complete maintenance history with filtering and search capabilities

### Statistics and Analytics
- **Monthly Summaries**: 
  - Total distance driven per month
  - Total fuel consumed
  - Total fuel costs
  - Average fuel consumption
  - Average price per liter/gallon

- **Time Period Analysis**: View statistics for:
  - All time
  - One month
  - Three months
  - One year
  - Year-to-date

- **Visual Data Representation**: Charts and graphs showing:
  - Fuel consumption trends
  - Fuel cost trends
  - Mileage progression
  - Maintenance history

### Monthly Recap
- **Monthly Reports**: Automated monthly summaries showing:
  - Total kilometers/miles driven
  - Total fuel used
  - Total fuel costs
  - Average consumption rates
- **Monthly Recap Notifications**: Optional push notifications for monthly summaries

### Data Management
- **Data Export**: Export vehicle data in JSON format
- **Data Reset Options**: Ability to reset fuel usage data or maintenance data separately
- **Settings Management**: Customizable app settings including:
  - Unit preferences (metric vs. imperial)
  - Notification settings
  - Default maintenance intervals

## Technical Features

### Platform and Technology
- **Platform**: iOS (native Swift/SwiftUI application)
- **Data Storage**: SwiftData for local data persistence
- **Architecture**: Clean architecture with Domain and Data layers
- **Analytics**: Firebase Analytics and Crashlytics integration
- **Push Notifications**: User notification support for monthly recaps and reminders

### User Experience
- **Onboarding Flow**: Guided setup process for new users
- **Dark Mode Support**: Full support for light and dark themes
- **Localization**: Support for multiple languages (English, Dutch)
- **Accessibility**: Designed with accessibility in mind

### Premium Features
- **In-App Purchases**: 
  - Premium monthly subscription
  - Premium yearly subscription
  - Lifetime premium purchase
- **Premium Benefits**: Enhanced features for premium users (unlimited history, advanced analytics)

## Target Audience

FuelTrackr is designed for:
- Individual vehicle owners who want to track fuel consumption and costs
- Fleet managers monitoring vehicle efficiency
- Environmentally conscious drivers tracking their fuel usage
- Budget-conscious users monitoring vehicle-related expenses
- Electric and alternative fuel vehicle owners tracking energy consumption

## Use Cases

1. **Personal Fuel Cost Tracking**: Monitor monthly fuel expenses and identify cost-saving opportunities
2. **Vehicle Efficiency Monitoring**: Track fuel consumption to identify changes in vehicle performance
3. **Maintenance Scheduling**: Keep track of maintenance intervals and service history
4. **Tax Deduction Documentation**: Maintain records of vehicle expenses for tax purposes
5. **Environmental Impact**: Monitor fuel consumption to reduce environmental footprint
6. **Vehicle Resale**: Maintain comprehensive records of vehicle maintenance and fuel history

## Key Differentiators

- Support for multiple fuel types (gasoline, diesel, electric, hydrogen)
- Automatic partial fill detection for accurate consumption calculations
- Comprehensive maintenance tracking integrated with fuel usage
- Monthly recap summaries with push notifications
- Clean, modern iOS interface with dark mode support
- Local data storage ensuring privacy and offline access

## App Information

- **App Name**: FuelTrackr
- **Platform**: iOS
- **Primary Language**: Swift
- **Framework**: SwiftUI
- **Minimum iOS Version**: iOS 10+
- **Bundle Identifier**: pepper-technologies.nl.FuelTrackr
