local obj = {}
obj.__index = obj
obj.__basename = "gtranslate"
obj.__name = "seal_" .. obj.__basename
obj.icon = hs.image.imageFromURL('https://www.google.com/s2/favicons?sz=64&domain_url=translate.google.com')
obj.api = 'https://translation.googleapis.com/language/translate/v2'
obj.timer_default = spoon.Seal.queryChangedTimerDuration
obj.timer_changed = false

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
        print('-- gtranslate : Missing key!')
        return false
    end
    return self.bareTranslate
end

function resetTimer()
    -- Set back the original time.
    if obj.timer_changed then
        spoon.Seal.queryChangedTimerDuration = obj.timer_default
        print('gtanslate queryChangedTimerDuration changed to default ' .. obj.timer_default)
    end
end

function obj.bareTranslate(query)
    local choices = {}
    if tostring(query):find('^%s*$') ~= nil then
        resetTimer()
        return choices
    end

    local lang, text = query:match('^tr (%a%a) (.*)$')
    if not lang or not text then
        resetTimer()
        return choices
    end

    langs = languages()
    if langs[lang:lower()] == nil then
        resetTimer()
        return choices
    end

    -- Temporary increase the query reaction time.
    print('gtanslate queryChangedTimerDuration changed to 1')
    spoon.Seal.queryChangedTimerDuration = 1
    obj.timer_changed = true

    -- If still empty give some feedback.
    if tostring(text):find('^%s*$') ~= nil then
        choices[1] = {
            text = 'Translating to ' .. langs[lang:lower()],
            subText = 'Type your search',
            image = obj.icon,
            plugin = obj.__name,
        }
        return choices
    end

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

        local choice = {}
        choice['text'] = result
        choice['subText'] = langs[lang:lower():lower()] .. ' translation for "' .. text .. '"'
        choice['url'] = 'https://translate.google.com/?sl=auto&op=translate&tl=' .. lang .. '&text=' .. q
        choice['image'] = obj.icon
        choice['plugin'] = obj.__name
        choice['type'] = 'openURL'
        choices[#choices + 1] = choice
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
