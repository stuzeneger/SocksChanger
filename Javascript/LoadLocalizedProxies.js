var btn = document.querySelector('button[onclick*="refresh(\'Africa\'"]');
btn.click();
setTimeout(function () {
    document.querySelector('div[onclick*="refresh(\'Africa\', \'GH\'"]').click();
    setTimeout(function () {
        document.querySelector('span.proxy_count[data-count="100"]').click();
        setTimeout(function () {
            console.log("MAINLIST:" + document.getElementById("main-list").innerHTML);
        }, 3000);
    }, 2000);
}, 3000);