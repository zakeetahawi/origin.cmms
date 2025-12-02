// Polyfill for process in web environment
if (typeof window !== 'undefined') {
    if (!window.process) {
        window.process = {
            env: { NODE_ENV: 'development' },
            platform: 'web',
            version: '',
            cwd: () => '/',
        };
    }
}

if (typeof global !== 'undefined') {
    if (!global.process) {
        global.process = {
            env: { NODE_ENV: 'development' },
            platform: 'web',
            version: '',
            cwd: () => '/',
        };
    }
}

// Polyfill for setImmediate (used by some react-native libs)
if (typeof setImmediate === 'undefined') {
    global.setImmediate = (fn) => setTimeout(fn, 0);
}
