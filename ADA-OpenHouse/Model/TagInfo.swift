//
//  Untitled.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 20/05/25.
//

struct TagInfo {
    let title: String
    let description: String
    let icon: String
}

var riddle: [String] = [
    "I hold the power, but I’m not a king. Tap me right, and the room will sing.",
    "I turn beans into liquid gold. Hot and strong, I never get old.",
    "Whatever the temperature. I quench your thirst.",
    "I bear the weight without complaint, Sit with me — your clue is quaint.",
    "Thoughts appear and vanish away, I help your brain come out and play.",
    "I chill the goods, I hum and glow. There’s more to me than what you know.",
    "I keep things safe, I hide them well. Only you know the key that opens me.",
    "You wash, you rinse, you go your way —",
    "Power flows from me to you, But I am hidden from plain sight."
]

var tagContent: [String: TagInfo] = [
    "0da6aa7c-20ed-44d1-a830-4b73bbf50633": TagInfo(
        title: "AV Controller",
        description: "Controls the projector, display, and speakers. Use it to start or stop presentations, adjust volume, or switch inputs.",
        icon: "av.remote.fill"
    ),
    "e421cdd7-e648-4fdb-9244-87d5c1a990bf": TagInfo(
        title: "Coffee Machine",
        description: "Brews fresh coffee. Insert a pod or fill with ground beans, then press the button to start brewing.",
        icon: "cup.and.heat.waves.fill"
    ),
    "32d14154-828b-4de1-9ce9-d7060afd7320": TagInfo(
        title: "Water Dispenser",
        description: "Provides cold and hot drinking water. Press the blue or red lever to fill your cup.",
        icon: "waterbottle.fill"
    ),
    "98d2f918-b190-4b37-84c2-c22e56c64b2b": TagInfo(
        title: "Table",
        description: "A surface for working, eating, or placing items. Use it for laptops, meetings, or lunch breaks.",
        icon: "table.furniture.fill"
    ),
    "f2de609f-beff-4fd4-838c-2eb6071477be": TagInfo(
        title: "Chair",
        description: "A seat for one person. Pull it out and sit comfortably while working or relaxing.",
        icon: "chair.fill"
    ),
    "4d7b0053-d71d-4157-9956-bc65704a5620": TagInfo(
        title: "Whiteboard",
        description: "A board for writing or drawing with markers. Use dry-erase markers to jot down ideas and wipe clean after use.",
        icon: "inset.filled.rectangle.and.person.filled"
    ),
    "3cd91ce0-f5f9-4619-9936-07e1d95fd5b1": TagInfo(
        title: "Refrigerator",
        description: "Keeps food and drinks cold. Open the door to store or grab chilled items; please label personal items.",
        icon: "refrigerator.fill"
    ),
    "1493b7a4-bd9e-41e0-b991-d76b833d11a5": TagInfo(
        title: "Locker",
        description: "A small, secure storage unit. Use your assigned key or code to lock away personal belongings.",
        icon: "shippingbox.fill"
    ),
    "9f3d86e2-9f6c-48e6-ba67-81bd7b6dbffd": TagInfo(
        title: "Sink",
        description: "A place to wash hands, dishes, or cups. Turn the faucet and use soap provided nearby.",
        icon: "sink.fill"
    ),
    "34b567d7-7755-47a5-b7dd-08a7893e41ee": TagInfo(
        title: "Collab Space Outlet",
        description: "Hidden power sockets around the space. Plug in your device to charge during work or meetings.",
        icon: "sofa.fill"
    )
]
