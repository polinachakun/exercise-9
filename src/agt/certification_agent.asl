// acting agent

/* Initial beliefs and rules */
// initial beliefs about certified reputation ratings for sensing agents
certified_reputation(certification_agent, sensing_agent_1, temperature(10), 0.9).
certified_reputation(certification_agent, sensing_agent_2, temperature(10), 0.9).
certified_reputation(certification_agent, sensing_agent_3, temperature(10), 0.9).
certified_reputation(certification_agent, sensing_agent_4, temperature(10), 0.9).

// initial beliefs about certified reputation ratings for rogue agents
certified_reputation(certification_agent, sensing_agent_5, temperature(8), -0.5).
certified_reputation(certification_agent, sensing_agent_6, temperature(8), -0.5).
certified_reputation(certification_agent, sensing_agent_7, temperature(8), -0.5).
certified_reputation(certification_agent, sensing_agent_8, temperature(8), -0.5).

// initial beliefs about certified reputation ratings for the rogue leader agent
certified_reputation(certification_agent, sensing_agent_9, temperature(-2), -0.9).

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start
    :  true
    <-  .print("Hello world");
    .

/* 
 * Plan for reacting to the addition of the belief certified_reputation(CertificationAgent, InteractingAgent, MessageContent, CRRating)
 * Triggering event: addition of the belief certified_reputation(CertificationAgent, InteractingAgent, MessageContent, CRRating)
 * Context: the agent believes that it is the CertificationAgent that created the certified reputation rating
 * Body: sends the certified reputation rating to the associated InteractingAgent
*/
+certified_reputation(CertificationAgent, InteractingAgent, MessageContent, CRRating)
    :  .my_name(CertificationAgent)
    <-  .send(InteractingAgent, tell, certified_reputation(CertificationAgent, InteractingAgent, MessageContent, CRRating));
    .


{ include("$jacamoJar/templates/common-cartago.asl") }