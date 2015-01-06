/* Implementation from: https://raw.githubusercontent.com/maxsnew/IO/master/elm-io.sh */
(function(){
    var stdin = process.stdin;
    var fs    = require('fs');
    var worker = Elm.worker(Elm.Main, {responses: null });
    var just = function(v) {
        return { 'Just': v};
    }
    var handle = function(request) {
        switch(request.ctor) {
        case 'Put':
            process.stdout.write(request.val);
            break;
        case 'Get':
            stdin.resume();
            break;
        case 'Exit':
            process.exit(request.val);
            break;
        case 'WriteFile':
            fs.writeFileSync(request.file, request.content);
            break;
        }
    }
    var handler = function(reqs) {
        for (var i = 0; i < reqs.length; i++) {
            handle(reqs[i]);
        }
        if (reqs.length > 0 && reqs[reqs.length - 1].ctor !== 'Get') {
            worker.ports.responses.send(just(""));
        }
    }
    worker.ports.requests.subscribe(handler);
    
    // Read
    stdin.on('data', function(chunk) {
        stdin.pause();
        worker.ports.responses.send(just(chunk.toString()));
    })

    // Start msg
    worker.ports.responses.send(null);
})();
