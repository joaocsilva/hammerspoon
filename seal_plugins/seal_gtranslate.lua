local obj = {}
obj.__index = obj
obj.__basename = "gtranslate"
obj.__name = "seal_" .. obj.__basename
obj.icon = spoon.Seal.plugins.useractions.favIcon('translate.google.com')
obj.api = 'https://translation.googleapis.com/language/translate/v2'
obj.url = 'https://translate.google.com/?sl=auto&op=translate&tl=%s&text=%s'
obj.timerDefault = spoon.Seal.queryChangedTimerDuration
obj.timerChanged = false

--- Seal.plugins.gtranslate.key
--- Variable
---
--- The api key from google translate.
obj.key = ''

function obj:commands()
    return {}
end

function obj:bare()
    if obj.key == '' then
        return false
    end
    return self.bareTranslate
end

function resetTimer()
    -- Set back the original time.
    if obj.timerChanged then
        spoon.Seal.queryChangedTimerDuration = obj.timerDefault
        obj.timerChanged = false
    end
end

function obj.bareTranslate(query)
    local choices = {}
    query = tostring(query)

    if query:find('^%s*$') ~= nil or query:find('^tr.*$') == nil then
        resetTimer()
        return choices
    end

    -- Default choice feedback when at least 'tr' is provided.
    choices[1] = {
        text = 'Translate',
        subText = 'Type "tr [lang] [text]"',
        image = obj.icon,
        plugin = obj.__name,
    }

    -- If no language is provided.
    local lang = query:match('^tr (%a%a).*$')
    if not lang then
        resetTimer()
        return choices
    end

    langs = languages()
    if langs[lang:lower()] == nil then
        resetTimer()
        choices[1].text = 'Language not found.'
        return choices
    end

    -- Language is present, give a better feedback.
    choices[1].text = 'Translate to ' .. langs[lang:lower()]
    choices[1].subText = 'Type "tr ' .. lang:lower() .. ' [text]"'

    lang, text = query:match('^tr (%a%a) (.*)$')
    if not lang or not text or tostring(text):find('^%s*$') ~= nil then
        resetTimer()
        return choices
    end

    -- Temporary increase the query reaction time.
    spoon.Seal.queryChangedTimerDuration = 1
    obj.timerChanged = true

    local q = hs.http.encodeForQuery(text)
    local payload = 'key=' .. obj.key .. '&q=' .. q .. '&target=' .. lang
    local status, data, table = hs.http.post(obj.api, payload)
    if status == 200 then
        local dataDecoded = hs.json.decode(data)
        local result = ''
        if dataDecoded and dataDecoded['data']['translations'] then
            for _, item in pairs(dataDecoded['data']['translations']) do
                if _ ~= 1 then
                    result = result .. ' | '
                end
                result = result .. item['translatedText']
            end
        end

        choices[1].text = result
        choices[1].subText = langs[lang:lower()] .. ' translation for "' .. text .. '"'
        choices[1].url = string.format(obj.url, lang, q)
        choices[1].type = 'openURL'
    end
    return choices
end

function obj.completionCallback(rowInfo)
    if rowInfo['type'] == 'openURL' then
        spoon.Seal.plugins.useractions.openURL(rowInfo['url'])
    end
end

-- Available languages.
-- @see https://cloud.google.com/translate/docs/languages
function languages()
    return {
        af = 'Afrikaans',
        sq = 'Albanian',
        am = 'Amharic',
        ar = 'Arabic',
        hy = 'Armenian',
        az = 'Azerbaijani',
        eu = 'Basque',
        be = 'Belarusian',
        bn = 'Bengali',
        bs = 'Bosnian',
        bg = 'Bulgarian',
        ca = 'Catalan',
        co = 'Corsican',
        hr = 'Croatian',
        cs = 'Czech',
        da = 'Danish',
        nl = 'Dutch',
        en = 'English',
        eo = 'Esperanto',
        et = 'Estonian',
        fi = 'Finnish',
        fr = 'French',
        fy = 'Frisian',
        gl = 'Galician',
        ka = 'Georgian',
        de = 'German',
        el = 'Greek',
        gu = 'Gujarati',
        ht = 'Haitian Creole',
        ha = 'Hausa',
        he = 'Hebrew',
        hi = 'Hindi',
        hu = 'Hungarian',
        is = 'Icelandic',
        ig = 'Igbo',
        id = 'Indonesian',
        ga = 'Irish',
        it = 'Italian',
        ja = 'Japanese',
        jv = 'Javanese',
        kn = 'Kannada',
        kk = 'Kazakh',
        km = 'Khmer',
        rw = 'Kinyarwanda',
        ko = 'Korean',
        ku = 'Kurdish',
        ky = 'Kyrgyz',
        lo = 'Lao',
        la = 'Latin',
        lv = 'Latvian',
        lt = 'Lithuanian',
        lb = 'Luxembourgish',
        mk = 'Macedonian',
        mg = 'Malagasy',
        ms = 'Malay',
        ml = 'Malayalam',
        mt = 'Maltese',
        mi = 'Maori',
        mr = 'Marathi',
        mn = 'Mongolian',
        my = 'Myanmar',
        ne = 'Nepali',
        no = 'Norwegian',
        ny = 'Nyanja',
        ps = 'Pashto',
        fa = 'Persian',
        pl = 'Polish',
        pt = 'Portuguese',
        pa = 'Punjabi',
        ro = 'Romanian',
        ru = 'Russian',
        sm = 'Samoan',
        gd = 'Scots Gaelic',
        sr = 'Serbian',
        st = 'Sesotho',
        sn = 'Shona',
        sd = 'Sindhi',
        si = 'Sinhala',
        sk = 'Slovak',
        sl = 'Slovenian',
        so = 'Somali',
        es = 'Spanish',
        su = 'Sundanese',
        sw = 'Swahili',
        sv = 'Swedish',
        tl = 'Tagalog',
        tg = 'Tajik',
        ta = 'Tamil',
        tt = 'Tatar',
        te = 'Telugu',
        th = 'Thai',
        tr = 'Turkish',
        tk = 'Turkmen',
        uk = 'Ukrainian',
        ur = 'Urdu',
        ug = 'Uyghur',
        uz = 'Uzbek',
        vi = 'Vietnamese',
        cy = 'Welsh',
        xh = 'Xhosa',
        yi = 'Yiddish',
        yo = 'Yoruba',
        zu = 'Zulu',
    }
end

return obj
