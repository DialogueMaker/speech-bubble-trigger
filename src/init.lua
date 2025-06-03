--!strict
-- Automatically triggers the dialogue server when the player clicks on a floating speech bubble.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");

local packages = script.Parent.roblox_packages;
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type Client = DialogueMakerTypes.Client;
type Conversation = DialogueMakerTypes.Conversation;

return function(client: Client)

  for _, conversationModuleScript in CollectionService:GetTagged("DialogueMaker_Conversation") do

    local didInitialize, errorMessage = pcall(function()

      -- We're using pcall because require can throw an error if the module is invalid.
      local conversation = require(conversationModuleScript) :: Conversation;
      local conversationSettings = conversation:getSettings();
      local speechBubbleGUI: BillboardGui? = conversationSettings.speechBubble.billboardGUI;
      local autoCreatedButton: GuiButton? = nil;
      
      if not speechBubbleGUI and conversationSettings.speechBubble.shouldAutoCreate then
        
        assert(conversationSettings.speechBubble.adornee, "SpeechBubble adornee must be set if shouldAutoCreate is enabled.");

        local autoCreatedSpeechBubbleGUI = script.SpeechBubbleGUI:Clone();
        autoCreatedSpeechBubbleGUI.Adornee = conversationSettings.speechBubble.adornee;
        autoCreatedSpeechBubbleGUI.Parent = conversationSettings.speechBubble.adornee;
        autoCreatedButton = autoCreatedSpeechBubbleGUI.Button;

      end;

      if speechBubbleGUI then

        assert(speechBubbleGUI:IsA("BillboardGui"), "SpeechBubble instance must be a BillboardGui.");

        local button = conversationSettings.speechBubble.button or autoCreatedButton;
        assert(button and button:IsA("GuiButton"), "SpeechBubble button must be a GuiButton.");

        client.DialogueChanged:Connect(function()
        
          speechBubbleGUI.Enabled = client:getDialogue() == nil;

        end);

        button.MouseButton1Click:Connect(function()

          if client:getDialogue() == nil then

            local dialogue = conversation:findNextVerifiedDialogue();
            if dialogue then
              
              speechBubbleGUI.Enabled = false;
              client:setDialogue(dialogue);

            end;

          end;
          
        end);

      end;

    end);

    if not didInitialize then

      local fullName = conversationModuleScript:GetFullName();
      warn(`[Dialogue Maker] Failed to initialize speech bubble for {fullName}: {errorMessage}`);

    end;

  end;

end;