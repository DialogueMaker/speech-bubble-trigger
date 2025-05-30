--!strict
-- Automatically triggers the dialogue server when the player clicks on a floating speech bubble.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");

local packages = script.Parent.roblox_packages;
local IClient = require(packages.client_types);
local IConversation = require(packages.conversation_types);

type Client = IClient.Client;
type Conversation = IConversation.Conversation;

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

        client.ConversationChanged:Connect(function()
        
          speechBubbleGUI.Enabled = client.conversation == nil;

        end);

        button.MouseButton1Click:Connect(function()

          if not client.conversation then

            client:interact(conversation);

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