//
//  MockData.swift
//  VenusHacksProject
//

import Foundation

enum MockData {
    static let bpWeek: [HealthStatPoint] = [
        .init(day: "M", value: 72), .init(day: "T", value: 80), .init(day: "W", value: 65),
        .init(day: "T", value: 78), .init(day: "F", value: 70), .init(day: "S", value: 74),
        .init(day: "S", value: 88),
    ]

    static let stepsWeek: [HealthStatPoint] = [
        .init(day: "M", value: 60), .init(day: "T", value: 75), .init(day: "W", value: 55),
        .init(day: "T", value: 70), .init(day: "F", value: 80), .init(day: "S", value: 65),
        .init(day: "S", value: 78),
    ]

    static let conditionOptions = [
        "Congenital heart disease (CHD)",
        "High blood pressure",
        "Diabetes",
        "Anxiety or depression",
        "None selected",
    ]

    static let complicationOptions = [
        "Preeclampsia",
        "Gestational diabetes",
        "Preterm birth",
        "None selected",
    ]

    static let allReels: [ReelItem] = [
        .init(
            id: 1,
            categories: ["chd", "advocacy", "heart"],
            grad: ["E05C97", "ED8DBB"],
            emoji: "",
            tag: "Heart Health",
            title: "Living with CHD as an Adult — What to Ask at Checkups",
            creator: "@dr.amara_heart",
            likes: "12.4K",
            badge: "Advocacy Pick",
            matchReason: "Matches your heart-health focus",
            verified: true
        ),
        .init(
            id: 2,
            categories: ["blood pressure", "postpartum"],
            grad: ["F0A500", "ED8DBB"],
            emoji: "",
            tag: "Blood Pressure",
            title: "Blood Pressure After Pregnancy: Why Follow-Up Matters",
            creator: "@herhealthmatters",
            likes: "9.1K",
            badge: nil,
            matchReason: "Postpartum wellness",
            verified: true
        ),
        .init(
            id: 3,
            categories: ["diabetes", "heart"],
            grad: ["2ABFBD", "ED8DBB"],
            emoji: "",
            tag: "Diabetes",
            title: "How Blood Sugar and Heart Health Are Connected",
            creator: "@nutritionfirst.md",
            likes: "8.9K",
            badge: nil,
            matchReason: "Diabetes and heart education",
            verified: false
        ),
        .init(
            id: 4,
            categories: ["pregnancy", "symptoms"],
            grad: ["B060C8", "E05C97"],
            emoji: "",
            tag: "Pregnancy",
            title: "Heart Symptoms Women Should Feel Comfortable Asking About",
            creator: "@heartmamas",
            likes: "21K",
            badge: "Community Story",
            matchReason: "General awareness",
            verified: false
        ),
        .init(
            id: 5,
            categories: ["advocacy", "heart"],
            grad: ["8B3A5E", "E05C97"],
            emoji: "",
            tag: "Advocacy",
            title: "How to Advocate at Your Next Cardiology Appointment",
            creator: "@herhealthmatters",
            likes: "34K",
            badge: "Must Watch",
            matchReason: "Self-advocacy",
            verified: true
        ),
        .init(
            id: 6,
            categories: ["nutrition", "general"],
            grad: ["F0A500", "ED8DBB"],
            emoji: "",
            tag: "Nutrition",
            title: "Anti-Inflammatory Meals for Heart Wellness",
            creator: "@nutritionfirst.md",
            likes: "5.2K",
            badge: nil,
            matchReason: "Wellness basics",
            verified: false
        ),
    ]

    static let communitySeeds: [CommunityMatchSeed] = [
        .init(id: UUID(), name: "Dr. Amara Osei", detail: "Cardiologist · CHD Specialist", avatar: "Dr", conditions: ["Congenital heart disease (CHD)"], lifeStage: "General", age: 42, interests: ["advocacy"], breastfeeding: false, verified: true, isGroup: false),
        .init(id: UUID(), name: "HeartMamas Group", detail: "Community · 2.4K members", avatar: "HM", conditions: ["High blood pressure"], lifeStage: "Postpartum", age: 30, interests: ["community"], breastfeeding: true, verified: true, isGroup: true),
        .init(id: UUID(), name: "NutritionFirst", detail: "Wellness coach · Anti-inflammatory", avatar: "NF", conditions: ["Diabetes"], lifeStage: "Pregnant", age: 29, interests: ["nutrition"], breastfeeding: false, verified: false, isGroup: true),
        .init(id: UUID(), name: "CardioCoach", detail: "Exercise · Cardiac-safe workouts", avatar: "CC", conditions: ["High blood pressure"], lifeStage: "General", age: 35, interests: ["movement"], breastfeeding: false, verified: false, isGroup: true),
        .init(id: UUID(), name: "Her Health Matters", detail: "Advocacy network · CHD focus", avatar: "HH", conditions: ["Congenital heart disease (CHD)"], lifeStage: "Postpartum", age: 31, interests: ["advocacy"], breastfeeding: false, verified: true, isGroup: true),
    ]

    static func milestones(for tab: RoadmapTab, profile: UserProfile) -> [RoadmapMilestone] {
        switch tab {
        case .pregnancy:
            return pregnancyMilestones(profile: profile)
        case .postpartum:
            return postpartumMilestones(profile: profile)
        case .lifetime:
            return lifetimeMilestones(profile: profile)
        }
    }

    private static func pregnancyMilestones(profile: UserProfile) -> [RoadmapMilestone] {
        let w = profile.weeksPregnant ?? 16
        return [
            .init(week: "Week 4",    label: "Prenatal Foundations",  sub: "Start prenatal care and ask about baseline health checks.",                                        icon: "", done: w > 4,  active: w <= 8,           tab: .pregnancy),
            .init(week: "Week 8",    label: "First Visits Prep",      sub: "Track symptoms and prepare questions for early visits.",                                           icon: "", done: w > 8,  active: w > 8 && w <= 12, tab: .pregnancy),
            .init(week: "Week 12",   label: "Early Screening",        sub: "Ask about blood pressure and early screening.",                                                    icon: "", done: w > 12, active: w > 12 && w <= 16, tab: .pregnancy),
            .init(week: "Week 16",   label: "Symptom Review",         sub: "Review any new symptoms with your care team.",                                                     icon: "", done: w > 16, active: w > 16 && w <= 20, tab: .pregnancy),
            .init(week: "Week 20",   label: "Anatomy Scan",           sub: "Ask what results mean for you — this may be worth discussing with your care team.",               icon: "", done: w > 20,                            tab: .pregnancy),
            .init(week: "Delivery",  label: "Delivery Day",           sub: "Know when to seek urgent help and who to contact.",                                                icon: "", done: false,                             tab: .pregnancy),
        ]
    }

    private static func postpartumMilestones(profile: UserProfile) -> [RoadmapMilestone] {
        [
            .init(week: "2 Weeks PP",  label: "Early Recovery Check-In",  sub: "Check blood pressure, mood, bleeding, and recovery.",                                        icon: "", done: false, active: true, tab: .postpartum),
            .init(week: "6 Weeks PP",  label: "Postpartum Visit",          sub: "Ask what care should continue beyond this visit.",                                           icon: "",                            tab: .postpartum),
            .init(week: "2 Months PP", label: "Long-Term Reminders",       sub: "Set reminders for longer-term heart-health checkups.",                                       icon: "",                            tab: .postpartum),
            .init(week: "6 Months PP", label: "Screening Discussion",      sub: "Review blood pressure, cholesterol, and diabetes screening if relevant.",                    icon: "",                            tab: .postpartum),
            .init(week: "1 Year PP",   label: "Annual Heart Care",         sub: "Keep heart health part of your annual care.",                                                icon: "",                            tab: .postpartum),
        ]
    }

    private static func lifetimeMilestones(profile: UserProfile) -> [RoadmapMilestone] {
        var items: [RoadmapMilestone] = [
            .init(week: "Ongoing", label: "Annual Checkup Reminder",    sub: "Preventive visits may help you stay ahead — schedule early when possible.",                     icon: "", active: true, tab: .lifetime),
            .init(week: "Ongoing", label: "Blood Pressure Awareness",   sub: "Know what numbers to track and when to call your care team.",                                   icon: "",               tab: .lifetime),
            .init(week: "Ongoing", label: "Cholesterol Discussion",     sub: "Ask when screening is right for you.",                                                          icon: "",               tab: .lifetime),
        ]
        if profile.conditions.contains(where: { $0.lowercased().contains("diabetes") }) {
            items.append(.init(week: "Ongoing", label: "Blood Sugar and Heart Health", sub: "Ask how diabetes may relate to long-term cardiovascular wellness.", icon: "", tab: .lifetime))
        }
        items.append(.init(week: "Future", label: "Lifetime Symptom Awareness", sub: "Risk does not mean certainty — awareness helps you advocate.", icon: "", tab: .lifetime))
        return items
    }
}
