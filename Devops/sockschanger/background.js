
let proxies = [];
var pendingRequests = [];

   fetch("http://127.0.0.1:8765/proxydata")
        .then(response => {
            if (!response.ok) {
                throw new Error("HTTP error " + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log("Saņemtie dati no lokālā servera:", data);
			const items = {
                proxySettings: data
            };
            
            console.log("Proxy iestatījumi sagatavoti:", items);
			
			proxies[1] = items.proxySettings;
			console.log('Set proxy on');
			browser.proxy.onRequest.addListener(handleProxyRequest, {urls: ["<all_urls>"]});
			browser.proxy.onError.addListener(error => {
			console.error(`Proxy error: ${error.message}`);
});

browser.webRequest.onAuthRequired.addListener(
    provideCredentialsSync,
    {urls: ["<all_urls>"]},
    ["blocking"]
);
browser.webRequest.onCompleted.addListener(
    completed,
    {urls: ["<all_urls>"]}
);
browser.webRequest.onErrorOccurred.addListener(
    completed,
    {urls: ["<all_urls>"]}
);
        })
        .catch(error => {
            console.error("Kļūda iegūstot datus no lokālā servera:", error);
			blockTraffic();
        });


function completed(requestDetails) {
     console.log("completed request: " + requestDetails.requestId);
     var index = pendingRequests.indexOf(requestDetails.requestId);
    if (index > -1) {
        pendingRequests.splice(index, 1);
    }
}

function provideCredentialsSync(requestDetails) {
    if (!requestDetails.isProxy)
        return;
    if (pendingRequests.indexOf(requestDetails.requestId) != -1) {
        console.log("Bad proxy credentials for request: " + requestDetails.requestId);
        return {cancel:true};
    }
    var credentials = {
        username: proxies[1].username,
        password: proxies[1].password
    }
    pendingRequests.push(requestDetails.requestId);

    console.log(`Providing proxy credentials for request: ${requestDetails.requestId} username: ${credentials.username}`);
    return {authCredentials: credentials};
}

function isLocalIPv4(host)
{
    var octets = /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/.exec(host);
    if(!octets)
        return false;
    if(octets[1]>255||octets[2]>255||octets[3]>255||octets[4]>255)
        return false;
    if(octets[1]==10||octets[1]==127) 
        return true;
    if(octets[1]==172&&octets[2]>=16&&octets[2]<=31)
        return true;
    if(octets[1]==192&&octets[2]==168) 
        return true;
    return false;
}

function isLocal(host)
{
    if(host.indexOf('.') == -1)
        return true;
    if(host.endsWith(".local"))
        return true;
    if(host=="::1")
        return true;
    return(isLocalIPv4(host));
}

function handleProxyRequest(requestInfo) {
    const url = new URL(requestInfo.url);
    var host = url.hostname;
    var proxyNum = 1;

        if(isLocal(host)) {
            console.log(`Local host detected: ${host}`);
            proxyNum = 0;
        }

        console.log(`Proxying: ${url.hostname}`);
        console.log(proxies[proxyNum]);
    
    return(proxies[proxyNum]);
}

function blockTraffic() {
    console.log("Bloķējam visu trafiku ar webRequest...");

    function cancelRequest(requestDetails) {
        console.log(`Pieprasījums bloķēts: ${requestDetails.url}`);
        return { cancel: true };
    }

    browser.webRequest.onBeforeRequest.addListener(
        cancelRequest,
        { urls: ["<all_urls>"] },
        ["blocking"]
    );
}



