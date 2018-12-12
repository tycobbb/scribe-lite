// types
declare namespace Module {
  var Elm: Elm

  interface Elm {
    Main: Main
  }

  interface Config {
    node:  Element | null,
    flags: any
  }

  interface InPort {
    send: (data: any) => void
  }

  interface OutPort {
    subscribe: (handler: (data: any) => void) => void
  }

  interface Main {
    init(config: Config): App
  }

  interface App {
    ports: {
      send: OutPort
      recv: InPort
    }
  }
}

// exports
export = Module
