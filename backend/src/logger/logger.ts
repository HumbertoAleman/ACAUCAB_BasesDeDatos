function now(): string {
    const n = new Date();
    const h = n.getHours().toString().padStart(2, '0');
    const m = n.getMinutes().toString().padStart(2, '0');
    return `${h}:${m}`;
}

enum DebugLevel {
	debug = 4,
	info = 3,
	warn = 2,
	error = 1,
	fatal = 0
}

export default class Logger {
	static #level: DebugLevel = DebugLevel.warn;

	static debug(message: string): void {
		if (this.#level < DebugLevel.debug)
			return
		console.log(`[DEBUG ${now()}]: ${message}`)
	}

	static info(message: string): void {
		if (this.#level < DebugLevel.info)
			return
		console.log(`[INFO ${now()}]: ${message}`)
	}

	static warn(message: string): void {
		if (this.#level < DebugLevel.warn)
			return
		console.log(`[WARN ${now()}]: ${message}`)
	}

	static error(message: string): void {
		if (this.#level < DebugLevel.error)
			return
		console.error(`[ERROR ${now()}]: ${message}`)
	}

	static fatal(message: string): void {
		if (this.#level < DebugLevel.fatal)
			return
		console.error(`[FATAL ${now()}]: ${message}`)
	}
}
