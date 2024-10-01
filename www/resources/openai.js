/*

  Chat Javascript library for OpenAI

  In this file we implement the client-side behavior of the chat
  implementation from xowiki/tcl/chat-procs.tcl

*/

function renderMessage(message, isme) {
    var messages = document.getElementById('xowiki-chat-messages');
    message_block = document.createElement('div');
    if (!isme) {
        message_block.className = 'mt-3 openai-message-block';
    } else {
        message_block.className = 'mt-3 openai-messageblock-me';
    }

    //
    // Message body
    //
    span = document.createElement('span');
    span.innerHTML = message;
    if (!isme) {
        span.className = 'xowiki-chat-message';
    } else {
        span.className = 'xowiki-chat-message-me';
    }
    message_block.appendChild(span);
    messages.appendChild(message_block);
    messages.scrollTop = messages.scrollHeight;
}

function renderData(json) {
  //
  // Render the message data
  //
  let body = JSON.parse(json.body);
  message = body.choices[0].message.content;
  renderMessage(message, false)
}

function initialize(url) {
    //
    // Send the message when the chat form is submitted.
    //
    const msgField = document.getElementById('xowiki-chat-send');
    document.querySelector('#xowiki-chat-send-button').addEventListener('click', (e) => {
        e.preventDefault();
        if (msgField.value === '') {
            return;
        }
        renderMessage(msgField.value, true);
        const httpSend = new XMLHttpRequest();
        var msg = `&content=${encodeURIComponent(msgField.value)}`;
        httpSend.open('GET', `${url}${msg}`);
        httpSend.onreadystatechange = () => {
            //
            // In local files, status is 0 upon success in Mozilla Firefox
            //
            if (httpSend.readyState === XMLHttpRequest.DONE) {
              const status = httpSend.status;
              if (status === 0 || (status >= 200 && status < 400)) {
                //
                // The request has been completed successfully
                //
                renderData(JSON.parse(httpSend.responseText), true);
              }
            }
          };
        httpSend.send();
        msgField.value = '';
    });

    //
    // The message field is focused by default.
    //
    msgField.focus();
}
