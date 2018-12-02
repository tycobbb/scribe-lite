export class Socket {
  constructor(send, recv) {
    this.send = send
    this.recv = recv
  }

  start() {
    this.send.subscribe((data) => {
      console.log("socket", "received:", data)

      setTimeout(() => {
        switch (data.name) {
          case "STORY.JOIN":
            this.respond({
              name: "STORY.SETUP",
              data: {
                text: "This is the first line.",
                name: "Mr. Socket"
              }
            }); break;
          case "STORY.ADD_LINE":
            this.respond({
              name: "STORY.ADD_LINE.OK",
              data: null
            }); break;
          default: break;
        }
      }, 100)
    })
  }

  respond(payload) {
    console.log("socket", "responding:", payload)
    this.recv.send(payload)
  }
}
