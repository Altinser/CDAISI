def chiffrement_lettre(l, d):
    return d.get(l, l) 

def chiffrement_phrase(p, d):
    res = ""
    for l in p: 
        res = res + chiffrement_lettre(l, d) 
    return res

def inverse_dico(d):
    res = {}
    for k in d: 
        v = d[k]
        res[v] = k
    return res

def dic_rot_13(): 
    return {"a": "n", "b": "o", "c": "p", "d": "q", "e": "r", "f": "s", "g": "t", "h": "u", "i": "v", "j": "w",
            "k": "x", "l": "y", "m": "z", "n": "a", "o": "b", "p": "c", "q": "d", "r": "e", "s": "f", "t": "g",
            "u": "h", "v": "i", "w": "j", "x": "k", "y": "l", "z": "m"}

def compte_lettres(p):
    alph = "abcdefghijklmnopqrstuvwxyz"
    res = {}
    for l in alph:
        if l != " ":
            res[l] = p.count(l)
    return res


def tri_bulles_dico(d):
    list_v = list(d.values())
    list_k = list(d.keys())

    for i in range(len(list_v)):
        for j in range(0, len(list_v) - i - 1):
            if list_v[j] < list_v[j + 1]:
                list_v[j], list_v[j + 1] = list_v[j + 1], list_v[j]
                list_k[j], list_k[j + 1] = list_k[j + 1], list_k[j]
    return list_k

def arrays2dict(ks, vs): 
    res = {}
    for i in range(0, len(ks)):
        res[ks[i]] = vs[i]
    return res

def decrypte(pc, ll):
    res = ""
    for l in pc:
        if l != " ":
            res = res + ll[l]
        else:
            res = res + l
    return res
  
if __name__ == '__main__':
    pc = "or z f kcgrkcgh fnnggh mg ug rofo onaougugna fqgb cn u eorrofu rgswfny or gafoa y cng fnbognng xfuorrg iwpaghafnag ga mfyoh or fqfoa gag woblg ufoh cng hgwog yg ufrlgcwh r fqfoa wgycoa f rf uohgwg ipcw gqoagw r lcuorofaopn yg hgh yghfhawgh or kcoaaf rf npcqgrrg pwrgfnh rf qorrg yg hgh fogcj ga gafdroa hf ygugcwg yfnh r org yg hcrroqfn iwgh blfwrghapn yfnh rf bfwprong yc hcy bgaag org gha ygh irch honscrogwgh grrg n gha scgwg bpuiphgg kcg yg hfdrg yg ugw ga f gnqowpn awpoh uorrgh yg rpns gn rfwsgcw grrg n f mfufoh irch y cn kcfwa yg uorrg grrg gha hgifwgg yc bpnaongna ifw cng bwokcg f igong qohodrg kco xorawg f awfqgwh cng ufhhg yg wphgfcj ga yg qfhg wgnygt qpch lfdoacgr ygh ipcrgh y gfc rf qgsgafaopn bpuug pn igca rg hciiphgw gha ifcqwg pc ipcw fonho yowg nfong pn n z awpcqg ifh y fwdwgh y cng bgwafong yougnhopn qgwh r gjawguoag pbboygnafrg f r gnywpoa pc h grgqgna rg xpwa upcrawog ga kcgrkcgh uohgwfdrgh dfaohhgh yg dpoh lfdoaggh ignyfna r gag ifw rgh sgnh kco xcogna rgh ipchhogwgh ga rgh xogqwgh yg blfwrghapn pn wgnbpnawg or gha qwfo rg ifruogw nfon hgaosgwg ufoh apcag r org f r gjbgiaopn yg bg ipona pbboygnafr ga y cn ghifbg awohag ga drfnblfawg kco dpwyg rf ugw gha bpcqgwag y gifohhgh dwpchhforrgh yg uzwag pypwoxgwfna ho ghaoug ifw rgh lpwaobcragcwh fnsrfoh r fwdchag z upnag hpcqgna f cng lfcagcw yg kcontg pc qonsa iogyh or z xpwug cn aforroh iwghkcg ouigngawfdrg ga blfwsg r fauphilgwg yg hgh ifwxcuh fc irch iwpxpny yg bg aforroh npn rpon yg r gjawguoag pwognafrg yg r org b gha f yowg yg rf irch grposngg rgswfny h gafoa dfao rco ugug cng igaoag lcaag kc or pbbcifoa kcfny ipcw rf iwguogwg xpoh ga ifw lfhfwy mg xoh hf bpnnfohhfnbg bgaag bpnnfohhfnbg ucwoa dogn qoag gn fuoaog bfw or z fqfoa bgwagh yfnh rg blgw wgbrch yg kcpo gjboagw r onagwga ga r ghaoug mg qoh kc or fqfoa wgbc cng xpwag gycbfaopn lgcwgchgugna hgwqog ifw ygh xfbcragh hiowoacgrrgh igc bpuucngh ufoh kc or gafoa onxgbag yg uohfnalwpiog ga hcmga f yg ufrlgcwgchgh fragwnfaoqgh y gnalpchofhug ga yg ugrfnbprog dogn kc or gca blgt rco dgfcbpci yg roqwgh or h gn hgwqfoa wfwgugna hgh iwonboifcj fuchgugnah bpnhohafogna f blfhhgw ga f igblgw pc f xrfngw hcw rf irfsg ga f awfqgwh rgh uzwagh gn kcgag yg bpkcorrfsgh ga y gblfnaorrpnh gnapuprpsokcgh hf bprrgbaopn fcwfoa ic xfowg gnqog f cn hefuugwyfu yfnh bgh gjbcwhopnh or gafoa pwyonfowgugna fbbpuifsng ifw cn qogcj ngswg npuug mcioagw kco fqfoa gag fxxwfnblo fqfna rgh wgqgwh yg rf xfuorrg ufoh kc pn n fqfoa ic ygboygw no ifw ugnfbgh no ifw iwpughhgh f fdfnypnngw hpn mgcng ufhhf eorr or bpnhoygwfoa bpuug hpn ywpoa yg rg hcoqwg ifwapca or n gha ifh ouiwpdfdrg kcg rgh ifwgnah yg rgswfny mcsgfna kcg bgrco bo fqfoa rf agag cn igc ygwfnsgg hg hpogna fiirokcgh f bpnxowugw mcioagw yfnh hpn pdhaonfaopn yfnh rg dca yg ugaawg cng ghigbg yg sfwyogn ga yg hcwqgorrfna fciwgh yc xcsoaox hpch rf rfaoacyg yg r org yg hcrroqfn rgh loqgwh hpna wfwgugna wospcwgcj ga b gha cn gqgngugna kcfny fc ygbron yg r fnngg rg xgc ygqogna onyohignhfdrg bgignyfna qgwh rg uorogc y pbapdwg or z gca cng mpcwngg y cn xwpoy wgufwkcfdrg mchag fqfna rg bpcblgw yc hprgor mg ug xwfzfoh cn blguon f awfqgwh rgh aforroh qgwh rf lcaag yg upn fuo kcg mg n fqfoh ifh qc ygicoh kcgrkcgh hgufongh mg ygugcwfoh frpwh f blfwrghapn f cng yohafnbg yg ngcx uorrgh yg r org ga rgh xfboroagh ipcw frrgw ga wgqgnow gafogna dogn uponh swfnygh kc fcmpcwy lco gn fwwoqfna f rf lcaag mg xwfiifo hgrpn upn lfdoacyg ga ng wgbgqfna ifh yg wgipnhg mg blgwblfo rf brgx pc mg hfqfoh kc grrg gafoa bfblgg m pcqwoh rf ipwag ga m gnawfo cn dgfc xgc xrfudfoa yfnh rg xpzgw b gafoa cng hcwiwohg ga f bpci hcw cng ygh irch fswgfdrgh mg ug ygdfwwfhhfo yg upn ifrgapa mg awfonfo cn xfcagcor fciwgh ygh dcblgh igaorrfnagh ga m faagnyoh ifaoguugna r fwwoqgg yg ugh lpagh igc fiwgh rf apudgg yg rf ncoa orh fwwoqgwgna ga ug xowgna cn fbbcgor apca f xfoa bpwyofr mcioagw apca gn wofna y cng pwgorrg f r fcawg hg ypnnfoa yc upcqgugna ga iwgifwfoa kcgrkcgh ipcrgh y gfc ipcw rg hpcigw rgswfny gafoa yfnh cng yg hgh bwohgh y gnalpchofhug bfw yg kcgr fcawg npu fiigrgw bgrf or fqfoa awpcqg cn doqfrqg onbpnnc xpwufna cn sgnwg npcqgfc ga uogcj gnbpwg or fqfoa blfhhg ga faawfig fqgb r fhhohafnbg yg mcioagw cn hbfwfdgg kc or bwpzfoa apca f xfoa npcqgfc ga hcw rgkcgr or yghowfoa fqpow upn pionopn rg rgnygufon ufaon"
    vs = "eaitsnlurodmcpvqhfbgjxywzk"
    d = compte_lettres(pc)
    ks = tri_bulles_dico(d)
    ll = arrays2dict(ks, vs)

    print("Texte chiffrer :\n",pc)
    print("Texte dechiffrer :\n",decrypte(pc, ll))
