/**
 * Prefix console.log/info/warn/error with ISO timestamps.
 * Disable with LOG_TIMESTAMPS=false in .env
 */
function patchConsoleTimestamps() {
    if (process.env.LOG_TIMESTAMPS === 'false') return;
    if (global.__consoleTimestampsPatched) return;
    global.__consoleTimestampsPatched = true;

    const stamp = () => new Date().toISOString();
    for (const level of ['log', 'info', 'warn', 'error']) {
        const original = console[level].bind(console);
        console[level] = (...args) => original(`[${stamp()}]`, ...args);
    }
}

module.exports = { patchConsoleTimestamps };
