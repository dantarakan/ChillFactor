# ChillFactor
iOS app created for GDC hackathon in Swift. Uploads user's heart rate from HealthKit and coordinates.

#### TableViewController.swift
Requests authorisation to use HealthKit and Location services, and uploads the data every 3 seconds to Firebase's REST API. Table was supposed to display closest venues along with their atmosphere, as received from the Node.js back-end.

#### HealthManager.swift
Used to interface with HealthKit.