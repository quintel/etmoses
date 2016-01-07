/*globals Blob*/
var CSV = {
    download: function (content, fileName, mimeType) {
        'use strict';

        var a = document.createElement('a');
        mimeType = mimeType || 'application/octet-stream';

        if (navigator.msSaveBlob) { // IE10
            return navigator.msSaveBlob(new Blob([content], { type: mimeType }),     fileName);
        }
        else if ('download' in a) { //html5 A[download]
            a.href = 'data:' + mimeType + ',' + encodeURIComponent(content);
            a.setAttribute('download', fileName);
            document.body.appendChild(a);
            setTimeout(function() {
                a.click();
                document.body.removeChild(a);
            }, 66);
            return true;
        }
        else { //do iframe dataURL download (old ch+FF):
            var f = document.createElement('iframe');
            document.body.appendChild(f);
            f.src = 'data:' + mimeType + ',' + encodeURIComponent(content);

            setTimeout(function() {
                document.body.removeChild(f);
            }, 333);
            return true;
        }
    }
};
