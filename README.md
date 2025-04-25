# Exercise 9: Trustworthy Agents

This repository contains a partial implementation of a [JaCaMo](https://jacamo-lang.github.io/) application where BDI agents coordinate with each other to achieve common goals within an organization based on a trust and reputation model.

## Table of Contents
- [Project structure](#project-structure)
- [Task 1](#task-1)
- [Task 2](#task-2)
- [Task 3](#task-3)
- [Task 4](#task-4)
- [How to run the project](#how-to-run-the-project)
- [Test with the real PhantomX Reactor Robot Arm](#test-with-the-real-phantomx-reactor-robot-arm)

## Project structure
```bash
├── additional-resources
│   └── org-rules.asl # provided rules for reasoning on (part of) an organization. Available in https://github.com/moise-lang/moise/blob/master/src/main/resources/asl/org-rules.asl
├── src
│   ├── agt
│   │   ├── inc
│   │   │   ├── interaction_trust_ratings.asl # provided interaction trust ratings of the acting agent  
│   │   │   └── skills.asl # provided plans for reacting to (some) organizational events.
│   │   ├── org_agent.asl # agent program of the organization agent that is responsible for initializing and managing a temperature monitoring organization
│   │   ├── sensing_agent.asl # agent program of the sensing agent that reads the temperature in the lab by using a weather station artifact
│   │   ├── rogue_agent.asl # agent program of the rogue agents that report temperature readings while being loyal to the rogue leader 
│   │   ├── rogue_leader_agent.asl # agent program of the rogue leader agent that reports temperature readings of its liking
│   │   ├── certification_agent.asl # agent program of the certification agent that holds and shares certified reputation ratings
│   │   └── acting_agent.asl # agent program of the acting agent that manifests the temperature in the lab by using a robotic arm Thing artifact and based on a trust and reputation model
│   ├── env
│   │    ├── tools
│   │    │   ├── WeatherStation.java # artifact that can be used for monitoring the temperature via the Open-Meteo Weather Forecast API (https://open-meteo.com/en/docs)
│   │    │   └── Converter.java # artifact that can be used for rescaling values
│   │    └── wot   
│   │        └── ThingArtifact.java # artifact that can be used for interacting with W3C Web of Things (WoT) Things
│   └── org   
│       └── org-spec.xml #  organization specification for monitoring the temperature in the lab
├── task1_2.jcm # the configuration file of the JaCaMo application for Task 1-2
└── task3_4.jcm # the configuration file of the JaCaMo application for Task 3-4
```

## Task 1
Modify the implementation in [`acting_agent.asl`](src/agt/acting_agent.asl) so that the acting agent manifests the temperature broadcasted by one of the agents with the highest average interaction trust rating.
- HINTS:
  - You can see the structure of interaction trust ratings in [`interaction_trust_ratings.asl`](src/agt/inc/interaction_trust_ratings.asl). These ratings are already included in `acting_agent.asl` (through the command `include`).
  - The [internal action `findall` of the jason.stdlib package](https://jason-lang.github.io/api/jason/stdlib/findall.html) can be used to query the belief base for beliefs of a certain structure. 
  - The [documentation of the jason.stdlib package](https://jason-lang.github.io/api/jason/stdlib/package-summary.html) contains information about basic internal actions that can facilitate the computation of (highest) average interaction trust ratings (e.g. by handling lists). 
    - Alternatively, computation can be facilitated through the use of artifacts that can assist in the computation. 
The [CArtAgO By Example Guide](https://www.emse.fr/~boissier/enseignement/maop13/courses/cartagoByExamples.pdf) contains examples on how to create and use classes that extend the class `Artifact`of CArtAgO.
  - Currently, the plan `@select_reading_task_0_plan` is used in [`acting_agent.asl`](src/agt/acting_agent.asl) for selecting a random received temperature reading to manifest. For completing Task 1, you can either modify this plan, or create a new plan (and also create the relevant goal within the `@manifest_temperature_plan`).  

## Task 2
Modify the implementation in [`rogue_agent.asl`](src/agt/rogue_agent.asl) so that the rogue agents broadcast only the temperature reading of the rogue leader agent. 
- HINTS: 
  - Currently, `rogue_agent.asl` overrides the plan `@read_temperature_plan` of [`sensing_agent.asl`](src/agt/sensing_agent.asl) with a plan for broadcasting one of the first 3 broadcasted temperature readings in the organization. For completing Task 3, your can either modify this plan, or create a new plan.
  - To check which agent has sent a message, you can use the annotation `source(AgentName)` (e.g. `source(jomi)`). 
  
## Task 3
Modify the implementations in [`sensing_agent.asl`](src/agt/sensing_agent.asl) and [`acting_agent.asl`](src/agt/acting_agent.asl) so that the acting agent asks all agents that have broadcasted a temperature reading for their certified reputation ratings. The acting agent should successfully receive the ratings, and manifest the temperature broadcasted by one of the agents with the highest rating (taking into consideration both certified reputation ratings and average interaction trust ratings).
- HINTS: 
  - The [`ask` illocutionary force](https://jason-lang.github.io/api/jason/stdlib/send.html) can be used (also with the internal action `.broadcast`) to request from other agents information of a specified structure (e.g. of the structure of certified reputation ratings).
  
## Task 4
- Modify the implementations of the following agents so that the agents send witness reputation ratings (of their liking) to the acting agent:
  - [`sensing_agent.asl`](src/agt/sensing_agent.asl)
  - [`rogue_agent.asl`](src/agt/rogue_agent.asl)
  - [`rogue_leader_agent.asl`](src/agt/rogue_leader_agent.asl) 
- Modify the implementation in [`acting_agent.asl`](src/agt/acting_agent.asl) so that the agent successfully receives the ratings, and manifests the temperature broadcasted by one of the agents with the highest rating (taking into consideration certified reputation ratings, average interaction trust ratings, and average witness reputation ratings).

## How to run the project
You can run the project directly in Visual Studio Code or from the command line with Gradle 7.4. The available Gradle tasks are:
- For Tasks 1-2 : `task1_2`
- For Tasks 3-4 `task3_4`

- In VSCode:  Click on the Gradle Side Bar elephant icon, and navigate to one of the Gradle tasks, e.g.: `GRADLE PROJECTS` > `exercise-9` > `Tasks` > `jacamo` > `task1_2`.
- MacOS and Linux: Use the command `./gradlew` to run one of the Gradle tasks, e.g.:
```shell
./gradlew task1_2
```
- Windows: Use the command `gradlew.bat` to run one of the Gradle tasks, e.g.:
```shell
gradle.bat task1_2
```

## Test with the real PhantomX Reactor Robot Arm
The application uses by default the robotic arm on dry-run to manifest the temperature (i.e. the `ThingArtifact` only prints the HTTP request to the robotic arm without executing the request). Follow these steps, if you want to test your application with the real [PhantomX Reactor Robot Arm](https://robosklep.com/en/robotic-arms/171-phantomx-reactor.html) that is located at the Interactions lab:
- Register as an operator of the robotic arm using the [HTTP API](https://app.swaggerhub.com/apis-docs/interactions-ics/Leubot/1.3.4#/user/addUser) of the arm and your credentials, e.g.:
```
curl --location 'https://api.interactions.ics.unisg.ch/leubot1/v1.3.4/user' 
--header 'Content-Type: application/json' 
--data-raw '{
    "name": "Fistname Lastname",
    "email": "firstname.lastname@unisg.ch"
}'
```
- The response to the above request should return a response with a `Location` header, for example: `Location: https://api.interactions.ics.unisg.ch/leubot1/v1.3.4/user/7c41d146cfd74ce06577abc7f18c1187`. There `7c41d146cfd74ce06577abc7f18c1187` is your new API key. 
- Copy & paste your API key to the body of the `manifest_temperature` plan of the [`acting_agent.asl`](src/agt/acting_agent.asl), so that the agent uses the arm as a registered operator.
- Finally, on the same plan, set the second initialization parameter for creating the `ThingArtifact` from `true` to `false`, so that the dry-run mode is deactivated.
- You can remotely observe the behavior of the robotic arm here: https://interactions.ics.unisg.ch/61-102/cam1/live-stream.
