Elm.Native.Text = {};
Elm.Native.Text.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Text = localRuntime.Native.Text || {};
    if (localRuntime.Native.Text.values)
    {
        return localRuntime.Native.Text.values;
    }

    var toCss = Elm.Native.Color.make(localRuntime).toCss;
    var Element = Elm.Graphics.Element.make(localRuntime);
    var NativeElement = Elm.Native.Graphics.Element.make(localRuntime);
    var List = Elm.Native.List.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);

    function makeSpaces(s) {
        if (s.length == 0)
        {
            return s;
        }
        var arr = s.split('');
        if (arr[0] == ' ')
        {
            arr[0] = "&nbsp;"
        }
        for (var i = arr.length; --i; ) {
            if (arr[i][0] == ' ' && arr[i-1] == ' ')
            {
                arr[i-1] = arr[i-1] + arr[i];
                arr[i] = '';
            }
        }
        for (var i = arr.length; i--; ) {
            if (arr[i].length > 1 && arr[i][0] == ' ')
            {
                var spaces = arr[i].split('');
                for (var j = spaces.length - 2; j >= 0; j -= 2) {
                    spaces[j] = '&nbsp;';
                }
                arr[i] = spaces.join('');
            }
        }
        arr = arr.join('');
        if (arr[arr.length-1] === " ")
        {
            return arr.slice(0,-1) + '&nbsp;';
        }
        return arr;
    }

    function properEscape(str) {
        if (str.length == 0)
        {
            return str;
        }
        str = str //.replace(/&/g,  "&#38;")
            .replace(/"/g,  '&#34;')
            .replace(/'/g,  "&#39;")
            .replace(/</g,  "&#60;")
            .replace(/>/g,  "&#62;")
            .replace(/\n/g, "<br/>");
        var arr = str.split('<br/>');
        for (var i = arr.length; i--; ) {
            arr[i] = makeSpaces(arr[i]);
        }
        return arr.join('<br/>');
    }

    // TODO: change text representation
    function fromString(str) {
        return Utils.txt(properEscape(str));
    }

    // TODO: change text representation
    function append(xs, ys) {
        return Utils.txt(Utils.makeText(xs) + Utils.makeText(ys));
    }

    // conversions from Elm values to CSS
    function toTypefaces(list) {
        var typefaces = List.toArray(list);
        for (var i = typefaces.length; i--; ) {
            var typeface = typefaces[i];
            if (typeface.indexOf(' ') > -1)
            {
                typefaces[i] = "'" + typeface + "'";
            }
        }
        return typefaces.join(',');
    }
    function toLine(line) {
        var ctor = line.ctor;
        return ctor === 'Under' ? 'underline' :
               ctor === 'Over'  ? 'overline'  : 'line-through';
    }

    // setting styles of Text
    // TODO: change text representation
    function style(style, text) {
        var newText = '<span style="color:' + toCss(style.color) + ';'
        if (style.typeface.ctor !== '[]')
        {
            newText += 'font-family:' + toTypefaces(style.typeface) + ';'
        }
        if (style.height.ctor !== "Nothing")
        {
            newText += 'font-size:' + style.height._0 + 'px;';
        }
        if (style.bold)
        {
            newText += 'font-weight:bold;';
        }
        if (style.italic)
        {
            newText += 'font-style:italic;';
        }
        if (style.line.ctor !== 'Nothing')
        {
            newText += 'text-decoration:' + toLine(style.line._0) + ';';
        }
        newText += '">' + Utils.makeText(text) + '</span>'
        return Utils.txt(newText);
    }

    // TODO: change text representation
    function height(px, text) {
        return { style: 'font-size:' + px + 'px;', text:text }
    }

    // TODO: change text representation
    function typeface(names, text) {
        return { style: 'font-family:' + toTypefaces(names) + ';', text:text }
    }

    // TODO: change text representation
    function monospace(text) {
        return { style: 'font-family:monospace;', text:text }
    }

    // TODO: change text representation
    function italic(text) {
        return { style: 'font-style:italic;', text:text }
    }

    // TODO: change text representation
    function bold(text) {
        return { style: 'font-weight:bold;', text:text }
    }

    // TODO: change text representation
    function link(href, text) {
        return { href: fromString(href), text:text };
    }

    // TODO: change text representation
    function line(line, text) {
        return { style: 'text-decoration:' + toLine(line) + ';', text:text };
    }

    // TODO: change text representation
    function color(color, text) {
        return { style: 'color:' + toCss(color) + ';', text:text };
    }

    function block(align) {
        return function(text) {
            var raw = {
                ctor :'RawHtml',
                html : Utils.makeText(text),
                align: align
            };
            var pos = A2(NativeElement.htmlHeight, 0, raw);
            return A3(Element.newElement, pos._0, pos._1, raw);
        }
    }

    function markdown(text) {
        var raw = {
            ctor:'RawHtml',
            html: text,
            align: null
        };
        var pos = A2(NativeElement.htmlHeight, 0, raw);
        return A3(Element.newElement, pos._0, pos._1, raw);
    }

    return localRuntime.Native.Text.values = {
        fromString: fromString,
        append: F2(append),

        height : F2(height),
        italic : italic,
        bold : bold,
        line : F2(line),
        monospace : monospace,
        typeface : F2(typeface),
        color : F2(color),
        link : F2(link),
        style : F2(style),

        leftAligned  : block('left'),
        rightAligned : block('right'),
        centered     : block('center'),
        justified    : block('justify'),
        markdown     : markdown,

        toTypefaces:toTypefaces,
        toLine:toLine
    };
};
