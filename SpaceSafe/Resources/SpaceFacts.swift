import SwiftUI

let spaceFacts: [LearnFact] = [

    LearnFact(
        emoji: "🛰️",
        title: "What is Space Debris?",
        body: """
Space debris is any human-made object orbiting Earth that no longer serves a useful purpose. This includes broken satellites, abandoned rocket stages, tools lost by astronauts, and fragments created during collisions or explosions in space.

Since the beginning of the Space Age in 1957, humanity has launched thousands of rockets and satellites into orbit. Over time, many of these missions ended, but the objects remained in space, endlessly circling Earth at enormous speeds.

Some debris is as large as buses, while other pieces are smaller than a grain of sand. Even tiny fragments are dangerous because orbital objects move incredibly fast.
""",
        color: .cyan,

        quiz: QuizQuestion(
            question: "Which of these is considered space debris?",
            answers: [
                "An active weather satellite",
                "A broken rocket stage left in orbit",
                "A cloud in Earth's atmosphere",
                "A natural asteroid"
            ],
            correctAnswer: "A broken rocket stage left in orbit"
        )
    ),

    LearnFact(
        emoji: "📊",
        title: "How Much Is Up There?",
        body: """
Scientists currently track more than 27,000 large debris objects orbiting Earth, but this is only a fraction of the real problem. Experts estimate there are around one million fragments larger than 1 centimetre.

Most of these fragments are impossible to track individually. They are too small for radar systems to monitor continuously, yet they still travel fast enough to damage spacecraft.

The amount of debris grows every year as more satellites are launched into orbit.
""",
        color: .purple,

        quiz: QuizQuestion(
            question: "Why are many debris fragments difficult to track?",
            answers: [
                "They move too slowly",
                "They are hidden behind the Moon",
                "They are too small for radar systems",
                "They only appear at night"
            ],
            correctAnswer: "They are too small for radar systems"
        )
    ),

    LearnFact(
        emoji: "💥",
        title: "Why Is It Dangerous?",
        body: """
Space debris moves at extraordinary speeds. In Low Earth Orbit, objects travel at around 28,000 kilometres per hour.

Even tiny fragments can destroy satellites or seriously damage spacecraft. A single collision may create thousands of new fragments, making the problem even worse.

Modern life depends heavily on satellites for communication, GPS navigation, weather forecasting, and scientific observation.
""",
        color: .red,

        quiz: QuizQuestion(
            question: "Why can tiny debris fragments still be dangerous?",
            answers: [
                "Because they are radioactive",
                "Because they travel extremely fast",
                "Because they contain fuel",
                "Because astronauts cannot see them"
            ],
            correctAnswer: "Because they travel extremely fast"
        )
    ),

    LearnFact(
        emoji: "🔗",
        title: "Kessler Syndrome",
        body: """
Kessler Syndrome describes a chain reaction where collisions in orbit create more debris, leading to even more collisions.

Scientists worry that if debris levels become too high, entire orbital regions could become unusable for future missions.

This scenario could make launching satellites much more dangerous in the future.
""",
        color: .orange,

        quiz: QuizQuestion(
            question: "What is Kessler Syndrome?",
            answers: [
                "A disease astronauts get in space",
                "A rocket engine failure",
                "A chain reaction of orbital collisions",
                "A type of satellite"
            ],
            correctAnswer: "A chain reaction of orbital collisions"
        )
    ),

    LearnFact(
        emoji: "🌍",
        title: "Which Orbit Is Most Affected?",
        body: """
Low Earth Orbit (LEO) is the most crowded orbital region around Earth. It stretches from around 200 to 2,000 kilometres above the planet.

The International Space Station and many commercial satellites operate in this region.

Because so many spacecraft share the same space, collision risks are constantly increasing.
""",
        color: .green,

        quiz: QuizQuestion(
            question: "Which orbital region contains the most debris?",
            answers: [
                "Deep Space",
                "Mars Orbit",
                "Low Earth Orbit",
                "Solar Orbit"
            ],
            correctAnswer: "Low Earth Orbit"
        )
    ),

    LearnFact(
        emoji: "📡",
        title: "What Satellites Are at Risk?",
        body: """
Communication satellites, GPS systems, and weather satellites are all vulnerable to debris impacts.

These systems are critical for modern life. GPS guides transportation systems, weather satellites track storms, and communication satellites power global internet and television services.

A major debris collision could disrupt services used by billions of people.
""",
        color: .blue,

        quiz: QuizQuestion(
            question: "Which service depends heavily on satellites?",
            answers: [
                "GPS navigation",
                "Ocean tides",
                "Volcano formation",
                "Forest growth"
            ],
            correctAnswer: "GPS navigation"
        )
    ),

    LearnFact(
        emoji: "🔭",
        title: "How Do We Track Debris?",
        body: """
Ground-based radar systems and powerful telescopes are used to monitor large debris objects orbiting Earth.

Space agencies share tracking information so satellite operators can avoid dangerous collisions.

Objects larger than 10 centimetres are usually trackable, but millions of smaller fragments remain difficult to monitor.
""",
        color: .cyan,

        quiz: QuizQuestion(
            question: "What tools are commonly used to track debris?",
            answers: [
                "Submarines",
                "Radar systems and telescopes",
                "Weather balloons",
                "Ocean sensors"
            ],
            correctAnswer: "Radar systems and telescopes"
        )
    ),

    LearnFact(
        emoji: "🚀",
        title: "How Fast Does Debris Travel?",
        body: """
Objects in Low Earth Orbit travel at around 7.8 kilometres per second.

That is more than 25 times faster than a bullet fired from a rifle. At these speeds, even tiny impacts release enormous amounts of energy.

This extreme velocity is one reason why cleaning up debris is so difficult.
""",
        color: .yellow,

        quiz: QuizQuestion(
            question: "Approximately how fast does debris travel in Low Earth Orbit?",
            answers: [
                "100 km/h",
                "1 km per second",
                "7.8 km per second",
                "50 metres per second"
            ],
            correctAnswer: "7.8 km per second"
        )
    ),

    LearnFact(
        emoji: "🧹",
        title: "Can We Clean It Up?",
        body: """
Several experimental missions aim to remove dangerous debris from orbit.

Ideas include robotic arms, giant nets, harpoons, magnetic capture systems, and even laser technology.

Cleaning space is extremely challenging because objects move so quickly and missions are very expensive.
""",
        color: .purple,

        quiz: QuizQuestion(
            question: "Which technology has been proposed for debris cleanup?",
            answers: [
                "Fishing nets in the ocean",
                "Robotic arms and capture nets",
                "Underground tunnels",
                "Weather satellites"
            ],
            correctAnswer: "Robotic arms and capture nets"
        )
    ),

    LearnFact(
        emoji: "📜",
        title: "Who Is Responsible?",
        body: """
Under international space law, countries are responsible for objects they launch into space.

However, there are currently no strict global rules forcing nations or companies to remove debris after missions end.

As space becomes more crowded, international cooperation will become increasingly important.
""",
        color: .orange,

        quiz: QuizQuestion(
            question: "Who is responsible for launched space objects under international law?",
            answers: [
                "Only NASA",
                "Private astronauts",
                "The country that launched them",
                "Nobody"
            ],
            correctAnswer: "The country that launched them"
        )
    ),

    LearnFact(
        emoji: "🌱",
        title: "What Are We Doing About It?",
        body: """
New international guidelines encourage satellites to safely deorbit within a few years after missions end.

Companies such as ClearSpace and Astroscale are developing commercial spacecraft designed specifically to remove debris.

Scientists hope these efforts will help keep Earth’s orbit usable for future generations.
""",
        color: .green,

        quiz: QuizQuestion(
            question: "What is one goal of modern debris regulations?",
            answers: [
                "Launch more junk into orbit",
                "Move satellites to Mars",
                "Deorbit satellites after missions end",
                "Ban all space travel"
            ],
            correctAnswer: "Deorbit satellites after missions end"
        )
    ),

    LearnFact(
        emoji: "👨‍🚀",
        title: "How Does This Affect Astronauts?",
        body: """
Astronauts aboard the International Space Station regularly face risks from orbital debris.

Sometimes the station must perform emergency manoeuvres to avoid incoming objects. In dangerous situations, astronauts may shelter inside docked spacecraft in case evacuation becomes necessary.

Debris safety is now an essential part of all human space missions.
""",
        color: .red,

        quiz: QuizQuestion(
            question: "What may astronauts do during a dangerous debris event?",
            answers: [
                "Go outside for repairs",
                "Shelter inside docked spacecraft",
                "Turn off gravity",
                "Land on the Moon"
            ],
            correctAnswer: "Shelter inside docked spacecraft"
        )
    )
]
