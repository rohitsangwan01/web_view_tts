// Android TTS Polyfill
// This file will inject TTS in Android WebView
// WebApi : https://wicg.github.io/speech-api/#dom-speechsynthesisutterance-voice

(function () {
  "use strict";

  if (window.speechSynthesis != undefined) {
    console.log("TTS Already Existed, skipping polyfill");
    return;
  }

  let native;
  let isNativeReady = false;

  window.SpeechSynthesisVoice = {
    voiceURI: "default",
    name: "default",
    lang: "default",
    localService: true,
    default: true,
  };

  // A Sample of English language
  let voices = [];

  window.SpeechSynthesisUtterance = function (text) {
    this.addEventListener = function (e) {};
    this.text = text;
    this.lang = undefined;
    this.voice = undefined; //SpeechSynthesisVoice?
    this.volume = undefined;
    this.rate = undefined;
    this.pitch = undefined;
    this.onstart = function (e) {};
    this.onend = function (e) {};
    this.onerror = function (e) {};
    this.onpause = function (e) {};
    this.onresume = function (e) {};
    this.onmark = function (e) {};
    this.onboundary = function (e) {};
  };

  window.getSpeechSynthesisUtterance = function (utterance) {
    return {
      text: utterance.text,
      lang: utterance.lang,
      volume: utterance.volume,
      rate: utterance.rate,
      pitch: utterance.pitch,
    };
  };

  let current_utterance = null;

  window.speechSynthesis = {
    pending: undefined, //boolean
    speaking: undefined, //boolean
    paused: undefined, //boolean
    onvoiceschanged: function (e) {
      console.log("voice changed");
    }, //EventHandler
    cancel: async function () {
      await native.sendMessage("cancel");
    },
    pause: async function () {
      await native.sendMessage("pause");
    },
    resume: async function () {
      await native.sendMessage("resume");
    },
    getVoices: function () {
      if (voices.length == 0) {
        return [SpeechSynthesisVoice];
      }
      return voices;
    },
    speak: async function (utterance) {
      current_utterance = utterance;
      return await native.sendMessage("speak", {
        data: getSpeechSynthesisUtterance(utterance),
      });
    },
  };

  // returns a promise with list of Voices
  window.getVoices = function () {
    return native.sendMessage("getVoices").then(function (response) {
      let voices_response = JSON.parse(response);
      console.log(`Got ${voices_response.length} voices`);
      var result = [];
      for (let i = 0; i < voices_response.length; i++) {
        let voice = JSON.parse(voices_response[i]);
        let voiceModel = {
          voiceURI: voice.name,
          name: voice.name,
          lang: voice.locale,
          localService: true,
          default: true,
        };
        result.push(voiceModel);
      }
      return result;
    });
  };

  native = {
    sendMessage: async function (type, sendMessageParms) {
      let message;
      sendMessageParms = sendMessageParms || {};
      let data = sendMessageParms.data || {};
      message = { type: type, data: data };
      // console.log(`SendNativeMessage : ${type}`);
      if (!isNativeReady) return;
      let result = await window.flutter_inappwebview.callHandler(type, {
        data: data,
      });
      if (result != undefined && result.error != undefined) {
        throw result.error;
      }
      return result;
    },
  };

  // Update Speak Events
  window.addEventListener(
    "flutterSpeakEventListener",
    (event) => {
      let data = JSON.stringify(event.detail);
      const eventType = JSON.parse(data).type;
      const eventData = JSON.parse(data).data;
      try {
        //console.log(`Event : ${eventType}`);
        if (current_utterance == null) return;
        //audio playing
        if (eventType == "start") {
          current_utterance.onstart(eventData);
        }
        // audio completed
        else if (eventType == "complete") {
          current_utterance.onend(eventData);
        }
        // audio resumed
        else if (eventType == "continue") {
          current_utterance.onresume(eventData);
        }
        // audio paused
        else if (eventType == "pause") {
          current_utterance.onpause(eventData);
        } // Got Error in Audio
        else if (eventType == "error") {
          current_utterance.onerror(eventData);
        }
      } catch (e) {
        console.log(`Event : ${eventType} , Error : ${e}`);
      }
    },
    false
  );

  // Update voices
  window.addEventListener(
    "flutterLanguageEventListener",
    (event) => {
      try {
        let data = JSON.stringify(event.detail);
        let languages = JSON.parse(data).languages;
        let voices_response = JSON.parse(languages);
        for (let i = 0; i < voices_response.length; i++) {
          let voice = JSON.parse(voices_response[i]);
          voices.push({
            voiceURI: voice.name,
            name: voice.name,
            lang: voice.locale,
            localService: true,
            default: true,
          });
        }
        if (voices.length == 0) {
          voices.push(SpeechSynthesisVoice);
        }
      } catch (e) {
        console.log(`ErrorEventUpdateVoice : ${e}`);
      }
    },
    false
  );

  window.addEventListener("flutterInAppWebViewPlatformReady", function (event) {
    isNativeReady = true;
  });

  //console.log("TTS Injected");
})();
