/*******************************************************************************
 * Copyright (c) 2020 THALES GLOBAL SERVICES.
 *  
 *  This program and the accompanying materials are made available under the
 *  terms of the Eclipse Public License 2.0 which is available at
 *  http://www.eclipse.org/legal/epl-2.0
 *  
 *  SPDX-License-Identifier: EPL-2.0
 *  
 *  Contributors:
 *     Thales - initial API and implementation
 *******************************************************************************/
/*
 * generated by Xtext 2.18.0.M3
 */
package org.polarsys.capella.scenario.editor.dsl.ui.contentassist
import org.polarsys.capella.scenario.editor.dsl.helpers.TextualScenarioHelper

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.Assignment
import org.polarsys.capella.scenario.editor.helper.EmbeddedEditorInstanceHelper
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.polarsys.capella.scenario.editor.dsl.textualScenario.Model
import org.polarsys.capella.scenario.editor.dsl.textualScenario.SequenceMessage
import org.polarsys.capella.scenario.editor.dsl.textualScenario.Participant
import org.polarsys.capella.core.model.helpers.CapellaElementExt
import org.polarsys.capella.scenario.editor.helper.DslConstants
import org.polarsys.capella.scenario.editor.dsl.textualScenario.StateFragment
import org.polarsys.capella.core.data.epbs.EPBSArchitecture
import org.polarsys.capella.scenario.editor.dsl.textualScenario.CreateMessage
import org.polarsys.capella.scenario.editor.dsl.textualScenario.DeleteMessage
import org.polarsys.capella.scenario.editor.dsl.textualScenario.ArmTimerMessage
import org.polarsys.capella.scenario.editor.dsl.textualScenario.SequenceMessageType
import org.polarsys.capella.core.data.cs.ExchangeItemAllocation
import org.polarsys.capella.scenario.editor.dsl.textualScenario.CombinedFragment
import java.util.HashMap
import org.polarsys.capella.scenario.editor.dsl.textualScenario.ParticipantDeactivation
import org.polarsys.capella.scenario.editor.dsl.textualScenario.Operand
import org.polarsys.capella.scenario.editor.dsl.textualScenario.Reference
import org.polarsys.capella.scenario.editor.dsl.textualScenario.LostMessage
import org.polarsys.capella.scenario.editor.dsl.textualScenario.FoundMessage

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class TextualScenarioProposalProvider extends AbstractTextualScenarioProposalProvider {
	/*
	 * filter the proposed keywords based on the context in which we edit the text scenario;
	 * check the context of the Capella Diagram - layer (OA, SA, LA, PA), type of scenario (IS, ES FS)
	 */
	override completeKeyword(Keyword keyword, ContentAssistContext contentAssistContext,
		ICompletionProposalAcceptor acceptor) {
		if (TextualScenarioHelper.isParticipantKeyword(keyword.value)) {
			if (EmbeddedEditorInstanceHelper.checkValidKeyword(keyword.getValue())) {
				super.completeKeyword(keyword, contentAssistContext, acceptor)
			}
		}
		else {
			// the message keywords are proposed separately
			val String[] messageKeywords = #["->", "->x", "->+", "->>", "->o", "o->"]
			if(!messageKeywords.contains(keyword.value)) {
				super.completeKeyword(keyword, contentAssistContext, acceptor)
			}
		}
	}
	
	override completeActor_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("actor", context, acceptor)
	}

	override completeComponent_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("component", context, acceptor)
	}

	override completeConfigurationItem_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("configuration_item", context, acceptor)
	}

	override completeFunction_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("function", context, acceptor)
	}

	override completeActivity_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("activity", context, acceptor)
	}

	override completeEntity_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("entity", context, acceptor)
	}

	override completeRole_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		getExistingParticipants("role", context, acceptor)
	}

	/*
	 * propose a list with the participants (parts that can be created
	 * if we have duplicated names in the list we can chose based on the id
	 */
	def getExistingParticipants(
		String keyword,
		ContentAssistContext context,
		ICompletionProposalAcceptor acceptor
	) {
		for (el : EmbeddedEditorInstanceHelper.getAvailableElements(keyword)) {
			var elementName = CapellaElementExt.getName(el)

			// if the name is already inserted in the text, do not propose it
			if (!participantAlreadyInserted(context.rootModel as Model, elementName, keyword)) {
				// create the proposal
				var proposal = createCompletionProposal("\"" + elementName + "\"", elementName, null,
					context) as ConfigurableCompletionProposal
				acceptor.accept(proposal);
			}
		}
	}

	/*
	 * propose a list with the timelines (for adding states, modes or allocated functions)
	 */
	def getExistingTimelines(String keyword, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		for (el : EmbeddedEditorInstanceHelper.getAvailableElements(keyword)) {
			var elementName = CapellaElementExt.getName(el)

			var proposal = createCompletionProposal("\"" + elementName + "\"", elementName, null,
				context) as ConfigurableCompletionProposal
			acceptor.accept(proposal);
		}
	}

	/*
	 * check if a participant is already used in the text
	 */
	def participantAlreadyInserted(Model model, String name, String keyword) {
		for (participant : model.participants) {
			if (participant.keyword == keyword && participant.name == name)
				return true
		}
		return false
	}

	override completeSequenceMessage_Source(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeParticipants(context, acceptor)
	}
	
	override completeSequenceMessage_Arrow(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		acceptor.accept(createCompletionProposal("->", "-> : Sequence Message", null, context))
	}

	override completeSequenceMessage_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeParticipants(context, acceptor)
	}
	
	override completeSequenceMessage_Name(EObject messageObj, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {

		var message = messageObj as SequenceMessage
		createMessageProposal(message.source, message.target, context, acceptor)
	}
	
	def createMessageProposal(String source, String target, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		// we obtain the type of exchanges allowed in this model
		// if we already have a CE (component exchange) we propose only CE
		// if we already have a FE (functional exchange) we propose only FE
		// if no message was yet declared in the xtext, we propose both (until a first message is declared)
		
		var scenarioExchangesType = TextualScenarioHelper.getScenarioAllowedExchangesType((context.rootModel as Model).elements)
		var exchangesAvailable = EmbeddedEditorInstanceHelper.getExchangeMessages(source, target)
		var elementName = new String
		for (EObject element : exchangesAvailable) {
			(context.rootModel as Model).elements
			if (EmbeddedEditorInstanceHelper.isInterfaceScenario) {
				elementName = CapellaElementExt.getName((element as ExchangeItemAllocation).allocatedItem)
			} else {
				elementName = CapellaElementExt.getName(element)
			}
			// in a scenario, cannot combine FE and CE in same scenario (functional and component exchanges)
			// if the type of exchange is allowed, propose it
			var exchangeType = TextualScenarioHelper.getExchangeType(element)
			if (scenarioExchangesType === null || scenarioExchangesType.equals(exchangeType)) {
				acceptor.accept(
					createCompletionProposal("\"" + elementName + "\"", "\"" + elementName + "\"", null, context))
			}
		}
	}
	
	override completeCreateMessage_Arrow(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (!EmbeddedEditorInstanceHelper.isFSScenario() && !EmbeddedEditorInstanceHelper.isESScenario()) {
			acceptor.accept(createCompletionProposal("->+", "->+ : Create Message", null, context))
		}
		
		if (EmbeddedEditorInstanceHelper.isInteractionScenario && !EmbeddedEditorInstanceHelper.isFSScenario()) {
			acceptor.accept(createCompletionProposal("->+", "->+ : Create Message", null, context))
		}
	}
	
	override completeCreateMessage_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var source = (model as CreateMessage).getSource()
		for (EObject el : TextualScenarioHelper.participantsDefinedBefore(context.rootModel as Model)) {
			if (!(el as Participant).name.equals(source)) {
				acceptor.accept(
					createCompletionProposal("\"" + (el as Participant).name + "\"", (el as Participant).name, null,
						context))
			}
		}
	}
	
	override completeCreateMessage_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		completeCreateDeleteMessageName(model, context, acceptor)
	}
	
	override completeDeleteMessage_Arrow(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (!EmbeddedEditorInstanceHelper.isFSScenario() && !EmbeddedEditorInstanceHelper.isESScenario()) {
			acceptor.accept(createCompletionProposal("->x", "->x : Delete Message", null, context))
		}
		
		if (EmbeddedEditorInstanceHelper.isInteractionScenario && !EmbeddedEditorInstanceHelper.isFSScenario()) {
			acceptor.accept(createCompletionProposal("->x", "->x : Delete Message", null, context))
		}
	}
	
	override completeDeleteMessage_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var source = (model as DeleteMessage).getSource()
		for (EObject el : TextualScenarioHelper.participantsDefinedBefore(context.rootModel as Model)) {
			if (!(el as Participant).name.equals(source)) {
				acceptor.accept(
					createCompletionProposal("\"" + (el as Participant).name + "\"", (el as Participant).name, null,
						context))
			}
		}
	}
	
	override completeParticipantDeactivation_Name(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
			var modelContainer = TextualScenarioHelper.getModelContainer(model as ParticipantDeactivation)
			var timelinesToPropose = new HashMap
			createTimelinesHashMapToProposeForDeactivation(model as ParticipantDeactivation, modelContainer as Model, timelinesToPropose)
			
			for (String timelineToPropose : timelinesToPropose.keySet) {
				if (timelinesToPropose.get(timelineToPropose) >= 1) {
					acceptor.accept(
					createCompletionProposal("\"" + timelineToPropose + "\"", timelineToPropose, null,
						context))
				}
			}	
	}
	
	def createTimelinesHashMapToProposeForDeactivation(ParticipantDeactivation participantDeactivation, EObject modelContainer, HashMap<String, Integer> timelinesToPropose)   {		
		var elements = TextualScenarioHelper.getElements(modelContainer)
		for (var i = 0; i < elements.size; i++) {
			if (elements.get(i).equals(participantDeactivation)) {
				for (var j = 0; j <= i; j++) {
					updateHashMap(timelinesToPropose, elements.get(j), participantDeactivation)
				}
				return timelinesToPropose
			}
			if (elements.get(i) instanceof CombinedFragment) {							
				createTimelinesHashMapToProposeForDeactivation(participantDeactivation, elements.get(i) as CombinedFragment, timelinesToPropose)
			}
			
			if (elements.get(i) instanceof Operand) {
				createTimelinesHashMapToProposeForDeactivation(participantDeactivation, elements.get(i) as Operand, timelinesToPropose)
			}
		}
		return timelinesToPropose
	}
	
	def updateHashMap(HashMap<String, Integer> timelinesToPropose, EObject element, ParticipantDeactivation participantDeactivation) {
			if (element instanceof SequenceMessage) {
				updateHashMapWithSequenceMessage(timelinesToPropose, element as SequenceMessage)
			}
			if (element instanceof ArmTimerMessage) {
				updateHashMapWithArmTimerMessage(timelinesToPropose, element as ArmTimerMessage)
			}

			if (element instanceof ParticipantDeactivation) {
				updateHashMapWithParticipantDeactivation(timelinesToPropose, element as ParticipantDeactivation)		
			}	
	}
	
	def updateHashMapWithSequenceMessage(HashMap<String, Integer> timelinesToPropose, SequenceMessage sequenceMessage) {
		if (sequenceMessage.execution !== null) {
			if (timelinesToPropose.containsKey(sequenceMessage.target)) {
				var value = timelinesToPropose.get(sequenceMessage.target)
				timelinesToPropose.put(sequenceMessage.target, (value as Integer) + 1)
			} else {
				timelinesToPropose.put(sequenceMessage.target, 1)
			}
		}
	}
	
	def updateHashMapWithArmTimerMessage(HashMap<String, Integer> timelinesToPropose, ArmTimerMessage armTimer) {
		if (armTimer.execution !== null) {
			if (timelinesToPropose.containsKey(armTimer.participant)) {
				var value = timelinesToPropose.get(armTimer.participant)
				value = (value as Integer) + 1
			} else {
				timelinesToPropose.put(armTimer.participant, 1)
			}
		}
	}
	
	def updateHashMapWithParticipantDeactivation(HashMap<String, Integer> timelinesToPropose, ParticipantDeactivation participantDeactivation) {
		if (timelinesToPropose.containsKey(participantDeactivation.name)) {
			var value = timelinesToPropose.get(participantDeactivation.name)
			timelinesToPropose.put(participantDeactivation.name, (value as Integer) - 1)
		}
	}
	
	override completeDeleteMessage_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		completeCreateDeleteMessageName(model, context, acceptor)
	}

	override completeArmTimerMessage_Arrow(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (!EmbeddedEditorInstanceHelper.isFSScenario()) {
			acceptor.accept(createCompletionProposal("->>", "->> : Arm Timer", null, context))
		}
	}
	
	override completeArmTimerMessage_Participant(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeParticipants(context, acceptor)
	}
	
	override completeArmTimerMessage_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		acceptor.accept(createCompletionProposal("\"Arm Timer\"", "\"Arm Timer\"", null, context))
	}
	
	override completeLostMessage_Arrow(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (EmbeddedEditorInstanceHelper.isESScenario()) {
			acceptor.accept(createCompletionProposal("->o", "->o : Lost Message", null, context))
		}
	}
	
	override completeLostMessage_Source(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeParticipants(context, acceptor)
	}
	
	override completeLostMessage_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var message = model as LostMessage
		createMessageProposal(message.source, null, context, acceptor)
	}
	
	override completeFoundMessage_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var message = model as FoundMessage
		createMessageProposal(null, message.target, context, acceptor)
	}
	
	override completeFoundMessage_Arrow(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (EmbeddedEditorInstanceHelper.isESScenario()) {
			acceptor.accept(createCompletionProposal("o->", "o-> : Found Message", null, context))
		}
	}
	
	override completeFoundMessage_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeParticipants(context, acceptor)
	}
	
	override completeStateFragment_Timeline(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var keywords = #[DslConstants.ACTOR, DslConstants.ACTIVITY, DslConstants.FUNCTION, DslConstants.ROLE,
			DslConstants.ENTITY, DslConstants.ROLE, DslConstants.COMPONENT, DslConstants.CONFIGURATION_ITEM]
		for (String keyword : keywords) {
			if (EmbeddedEditorInstanceHelper.checkValidKeyword(keyword)) {
				getExistingTimelines(keyword, context, acceptor)
			}
		}
	}

	override completeStateFragment_Keyword(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var keywords = newArrayList(DslConstants.STATE, DslConstants.MODE)
		var scenarioType = EmbeddedEditorInstanceHelper.getScenarioType();
		var scenarioLevel = EmbeddedEditorInstanceHelper.getScenarioLevel();
		if (! scenarioType.equals(DslConstants.FUNCTIONAL) && ! (scenarioLevel instanceof EPBSArchitecture)) {
			keywords.add(DslConstants.FUNCTION)
		}
		for (String keyword : keywords) {
			acceptor.accept(createCompletionProposal(keyword, keyword, null, context))
		}

	}

	override completeStateFragment_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		for (String stateFragment : EmbeddedEditorInstanceHelper.getAvailableStateFragments(
			(model as StateFragment).keyword, (model as StateFragment).timeline)) {
			acceptor.accept(
				createCompletionProposal("\"" + stateFragment + "\"", "\"" + stateFragment + "\"", null, context))
		}

	}
	
	override completeCombinedFragment_Timelines(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		for (EObject el : TextualScenarioHelper.participantsDefinedBefore(context.rootModel as Model)) {
			if (!(model as CombinedFragment).timelines.contains((el as Participant).name)) {
				acceptor.accept(
					createCompletionProposal("\"" + (el as Participant).name + "\"", (el as Participant).name, null,
						context))
			}
		}
	}
	
	override completeReference_Name(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var referencedScenarios = EmbeddedEditorInstanceHelper.getReferencedScenariosName()
		for (referencedScenario : referencedScenarios) {
			acceptor.accept(createCompletionProposal("\"" + referencedScenario + "\"", referencedScenario, null, context))
		}
	}
	
	override completeReference_Timelines(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		for (EObject el : TextualScenarioHelper.participantsDefinedBefore(context.rootModel as Model)) {
			if (!(model as Reference).timelines.contains((el as Participant).name)) {
				acceptor.accept(
					createCompletionProposal("\"" + (el as Participant).name + "\"", (el as Participant).name, null,
						context))
			}
		}
	}

	/*
	 * check if a message is already used in the text
	 */
	def messageAlreadyInserted(Model model, String source, String target, String name) {
		for (element : model.elements) {
			if (element instanceof SequenceMessage) {
				var message = element as SequenceMessage
				if (message.name == name && message.source == source && message.target == target)
					return true
			}
		}
		return false
	}

	def completeCreateDeleteMessageName(EObject model, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var message = model as SequenceMessageType
		var exchangesAvailable = EmbeddedEditorInstanceHelper.getExchangeMessages(message.getSource, message.getTarget)
		var elementName = new String
		for (EObject element : exchangesAvailable) {
			if (EmbeddedEditorInstanceHelper.isInterfaceScenario) {
				elementName = CapellaElementExt.getName((element as ExchangeItemAllocation).allocatedItem)
			} else {
				elementName = CapellaElementExt.getName(element)
			}
			if (elementName !== null) {
				acceptor.accept(
					createCompletionProposal("\"" + elementName + "\"", "\"" + elementName + "\"", null, context))
			}
		}
	}
	
	def proposeParticipants(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		for (EObject el : TextualScenarioHelper.participantsDefinedBefore(context.rootModel as Model)) {
			acceptor.accept(
				createCompletionProposal("\"" + (el as Participant).name + "\"", (el as Participant).name, null,
					context))
		}
	}
}
