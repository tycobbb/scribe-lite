import { InPort, OutPort } from "../App/Main"

export class Socket {
  private send:     OutPort
  private recv:     InPort
  private messages: any[];
  private socket:   WebSocket | null

  constructor(send: OutPort, recv: InPort) {
    this.send     = send
    this.recv     = recv
    this.messages = []
    this.socket   = null
  }

  start() {
    this.socket           = new WebSocket("ws://localhost:8080")
    this.socket.onopen    = this.flush
    this.socket.onmessage = this.handle

    this.send.subscribe(this.enqueue)
  }

  // push messages
  private enqueue = (message: any) => {
    const state = this.socket!.readyState
    if (state == WebSocket.CLOSED || state == WebSocket.CLOSING) {
      return
    }

    this.messages.push(message)
    console.debug("socket", "enqueued:", message)

    if (state == WebSocket.OPEN) {
      this.flush()
    }
  }

  private flush = () => {
    for (const message of this.messages) {
      const json = JSON.stringify(message)
      this.socket!.send(json)
    }

    this.messages = []
  }

  // handle events
  private handle = (event: MessageEvent) => {
    console.debug("socket", "received:", event.data)

    if (event.data) {
      const json = JSON.parse(event.data)
      this.recv.send(json)
    }
  }
}
