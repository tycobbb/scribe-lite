export class Socket {
  constructor(send, recv) {
    this.send = send
    this.recv = recv
  }

  start() {
    this.send.subscribe((data) => {
      console.log(data)
    })

    setTimeout(() => {
      this.recv.send({
        name: "STORY.SETUP",
        data: {
          text: "This is the first line.",
          name: "Mr. Socket"
        }
        // error: {
        //   message: "Nope."
        // }
      })
    }, 500);
  }
}
