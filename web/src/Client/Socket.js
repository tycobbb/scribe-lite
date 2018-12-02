export class Socket {
  constructor(send, recv) {
    this.send = send
    this.recv = recv
  }

  start() {
    this.send.subscribe((data) => {
      setTimeout(() => {
        switch (data.name) {
          case "STORY.JOIN":
            this.recv.send({
              name: "STORY.SETUP",
              data: {
                text: "This is the first line.",
                name: "Mr. Socket"
              }
            })
          default: break;
        }
      }, 100)
    })
  }
}
