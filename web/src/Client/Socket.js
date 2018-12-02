export class Socket {
  constructor(send, recv) {
    this.send = send
    this.recv = recv
  }

  start() {
    switch (data.name) {
      case "STORY.JOIN":
        setTimeout(() => {
          this.recv.send({
            name: "STORY.SETUP",
            data: {
              text: "This is the first line.",
              name: "Mr. Socket"
            }
          })
        }, 100)
      default: break;
    }
  }
}
