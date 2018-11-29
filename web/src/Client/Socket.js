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
        name: "JOIN_STORY",
        // data: {
        //   title: "cool"
        // }
        error: {
          message: "Nope."
        }
      })
    }, 500);
  }
}
