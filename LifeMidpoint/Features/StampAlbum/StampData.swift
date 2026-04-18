import Foundation

// MARK: - Stamp Models

struct StampInfo: Identifiable, Hashable {
    let id: String        // unique key
    let name: String      // 邮票名
    let imageName: String // Asset 名
    let description: String

    static func == (l: StampInfo, r: StampInfo) -> Bool { l.id == r.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct StampSeriesData: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let stamps: [StampInfo]
    let collectedCount: Int

    var totalCount: Int { stamps.count }
}

// MARK: - 全部邮票数据 (来自 docx 设计文档)

enum StampLibrary {

    static let goldStamps: [StampInfo] = [
        StampInfo(id: "gold_1", name: "波动之间", imageName: "GoldStamp1",
                  description: "xxxx 年 x 月 x 日，潮汐留下了纹路。\n那一天，风并不很大，海也不喧哗。潮水来过，又悄悄退去，把层层起伏留在沙地上。你忽然明白，情绪有高有低，本来就和呼吸一样自然。那些深浅不一的痕迹，正是你认真活过的证据。"),
        StampInfo(id: "gold_2", name: "情绪采样者", imageName: "GoldStamp2",
                  description: "xxxx 年 x 月 x 日，内心的天气被轻轻收集。\n你开始不再只用简单的词语形容自己。盛开的、半合的、低垂的，那些细微不同的心绪，被你一一辨认、命名、安放。理解自己，从来都藏在这些温柔的靠近里。每一种感受，都值得被看见。"),
        StampInfo(id: "gold_3", name: "第一封寄出", imageName: "GoldStamp3",
                  description: "xxxx 年 x 月 x 日，心意第一次有了去处。\n那是一封真正被写完的信，安静地躺在晨光里，薄薄一页，却装下了许多没来得及说出口的话。你第一次把心意交给纸张，再交给远方。从那一刻起，表达有了方向，想念也有了抵达的可能。"),
        StampInfo(id: "gold_4", name: "仍在书写", imageName: "GoldStamp4",
                  description: "xxxx 年 x 月 x 日，你带着停顿，重新回来。\n人总会走远一阵子，也会沉默一阵子。可在某一个雨后或天光微亮的时刻，你又一次翻开了新的一页。笔还在，纸还在，你也还在。于是那些未完成的句子，重新有了继续写下去的勇气。"),
        StampInfo(id: "gold_5", name: "缓缓回温", imageName: "GoldStamp5",
                  description: "xxxx 年 x 月 x 日，寒意开始松动。\n那只是一个很小的片刻：一杯热水，一本摊开的手账，一束安静落下的光。你终于愿意坐下来，陪自己待一会儿，让身体和心慢慢回暖。"),
        StampInfo(id: "gold_6", name: "四时有迹", imageName: "GoldStamp6",
                  description: "xxxx 年 x 月 x 日，时间在你身上留下了季节。\n你看着一棵树从嫩绿走到繁盛，再从金黄走向清瘦，也看见自己走过的那些日子。成长总是悄悄发生，像四时流转，无声，却处处有迹。"),
        StampInfo(id: "gold_7", name: "初次留痕", imageName: "GoldStamp7",
                  description: "xxxx 年 x 月 x 日，你第一次认真看见了自己。\n那只是很轻的一笔，很短的一段话，很小的一次停顿。可也正是从这里开始，情绪不再只是模糊地经过，而第一次被你留在纸上。"),
        StampInfo(id: "gold_8", name: "旧字重逢", imageName: "GoldStamp8",
                  description: "xxxx 年 x 月 x 日，旧日的字句重新发光。\n一只木盒被轻轻打开，过去没有立刻涌来，只是安静地躺在那里，等你翻开。那些曾经写下的心意、折痕、花叶和书签，都在提醒你。"),
        StampInfo(id: "gold_9", name: "一月成册", imageName: "GoldStamp9",
                  description: "xxxx 年 x 月 x 日，日子被一页页装订起来。\n三十天并不算漫长，却足够让零散的心绪慢慢有了厚度。它像一段时间的侧影，被你用耐心与目光，安静地保存下来。"),
        StampInfo(id: "gold_10", name: "回望之眼", imageName: "GoldStamp10",
                  description: "xxxx 年 x 月 x 日，过去在水光里慢慢显形。\n你翻开旧页，风轻轻吹起纸张，湖面也映出柔和的天色。很多答案都藏在回望里，藏在你重新凝视自己的那些时刻。"),
        StampInfo(id: "gold_11", name: "回音抵达", imageName: "GoldStamp11",
                  description: "xxxx 年 x 月 x 日，山海有了回响。\n那是你第一次收到远方的寄托。一张薄纸，万钧之重。它从黄昏出发，掠过无数个黄昏，最终停靠在你的频率里。"),
        StampInfo(id: "gold_12", name: "鎏金典藏", imageName: "GoldStamp12",
                  description: "xxxx 年 x 月 x 日，散落的光阴终于被你收藏。\n一路走来的日常、情绪、停顿、回望与重新开始，被你一点一点拾起，安静地收进行囊。至此，成长从流逝的时间，变成了一套属于你的个人典藏。"),
        StampInfo(id: "gold_13", name: "百日留金", imageName: "GoldStamp13",
                  description: "xxxx 年 x 月 x 日，普通日子开始发光。\n一百天缓慢经过，很多细碎时刻也被你一一留住。它们原本平凡，甚至容易被忽略，可在持续的记录里，慢慢沉淀出珍贵的光泽。"),
        StampInfo(id: "gold_14", name: "接住自己", imageName: "GoldStamp14",
                  description: "xxxx 年 x 月 x 日，夜晚替你留了一盏灯。\n有些时刻很安静，安静到只剩一盏小灯、一杯水、一本合上的书，和你自己。你坐在那里，没有急着赶路，也没有催促情绪快点散去。你只是轻轻地，把自己安放好。")
    ]

    static let midpointStamps: [StampInfo] = [
        StampInfo(id: "mid_14", name: "落点", imageName: "MidpointStamp14",
                  description: "xxxx 年 x 月 x 日，某个瞬间被轻轻标记。\n人生里总有这样一个点，看上去很小，落下去却会荡开一圈圈回响。它未必轰轰烈烈，也未必立刻改变什么，只是让你第一次意识到：原来自己已经走到了这里。"),
        StampInfo(id: "mid_15", name: "转弯", imageName: "MidpointStamp15",
                  description: "xxxx 年 x 月 x 日，方向开始缓缓偏移。\n那条线原本一直向前，安静、平稳、没有太多波澜。直到某一刻，它轻轻弯了一下，像人生终于长出了属于自己的弧度。"),
        StampInfo(id: "mid_16", name: "交汇", imageName: "MidpointStamp16",
                  description: "xxxx 年 x 月 x 日，过去与未来在此交汇。\n有些时刻像树枝从一个点向四周生长，向上、向下、向远处，也向更深的自己延伸。你站在中间，同时感到来路与去路都在身上发芽。"),
        StampInfo(id: "mid_17", name: "留白", imageName: "MidpointStamp17",
                  description: "xxxx 年 x 月 x 日，圆环仍留着一个缺口。\n走到这里，你开始明白，人生从来不需要被完整封闭。总会有未完成的部分，总会有还在等待的空白，总会有一个小小的缺口，为新的光、新的风、新的可能留出入口。")
    ]

    static let migrationStamps: [StampInfo] = [
        StampInfo(id: "mig_18", name: "潮边短歇", imageName: "MigrationStamp18",
                  description: "xxxx 年 x 月 x 日，潮水为旅途留出了一小块岸。\n远方还没有走完，风也还在吹，可它先停下来，在湿润的沙地上留下细小的足迹。归途有时并不需要太多答案，只需要一处可以稍作停歇的安静。"),
        StampInfo(id: "mig_19", name: "月下辨途", imageName: "MigrationStamp19",
                  description: "xxxx 年 x 月 x 日，月光替归途照亮了一段路。\n夜色很深，云层缓缓移开，一轮月亮悬在高处。它们从月下飞过，羽翼安静，方向却始终清晰。"),
        StampInfo(id: "mig_20", name: "雾湖长翼", imageName: "MigrationStamp20",
                  description: "xxxx 年 x 月 x 日，长翼掠过薄雾与水光。\n清晨的湖面还未完全醒来，远山在雾里若隐若现。它从水面上方滑翔而过，影子也被一同带走。归家的路在这一刻显得很长，也很轻。"),
        StampInfo(id: "mig_21", name: "逆风而行", imageName: "MigrationStamp21",
                  description: "xxxx 年 x 月 x 日，寒意没有让翅膀停下。\n风雪并不盛大，却足够让空气变冷、让前路变白。它仍朝前飞去，像许多不被看见的坚持一样，安静、单薄，却没有折返。"),
        StampInfo(id: "mig_22", name: "归枝已定", imageName: "MigrationStamp22",
                  description: "xxxx 年 x 月 x 日，枝头终于接住了远行的身影。\n它们并肩停下，水面安静，天色也正一点点变柔。长路在这一刻有了落点，漂泊也终于不再漂泊。"),
        StampInfo(id: "mig_23", name: "落水成纹", imageName: "MigrationStamp23",
                  description: "xxxx 年 x 月 x 日，水面替归途记下了一圈圈回声。\n翅膀还未完全收拢，脚尖已经先触到湖面，细小波纹一层层散开。"),
        StampInfo(id: "mig_24", name: "檐下归巢", imageName: "MigrationStamp24",
                  description: "xxxx 年 x 月 x 日，屋檐重新成为归途的终点。\n春意刚刚从木梁边探出一点嫩芽，它已经掠过熟悉的屋檐。"),
        StampInfo(id: "mig_25", name: "斜阳归影", imageName: "MigrationStamp25",
                  description: "xxxx 年 x 月 x 日，黄昏把归途拉成了一道影子。\n天色从浅蓝慢慢过渡到柔粉和橙光，鸟群斜斜飞过，像在暮色里写下一行极轻的句子。"),
        StampInfo(id: "mig_26", name: "启程", imageName: "MigrationStamp26",
                  description: "xxxx 年 x 月 x 日，远方先在天际线上亮起。\n河流在脚下缓缓延伸，天空还带着清晨未散的颜色。它们已经排好方向，向更远处飞去。")
    ]

    static let flowerStamps: [StampInfo] = [
        StampInfo(id: "flower_27", name: "桃枝含春", imageName: "FlowerStamp27",
                  description: "xxxx 年 x 月 x 日，春意先落在了一枝桃花上。\n那些浅浅的粉，沿着枝条一点点舒展开来，像刚刚被晨光唤醒的心事，柔软、轻盈，又带着最初的温度。"),
        StampInfo(id: "flower_28", name: "玉枝含光", imageName: "FlowerStamp28",
                  description: "xxxx 年 x 月 x 日，白色在枝头安静发亮。\n花瓣被光轻轻托起，显得干净、从容，又有一种不动声色的力量。"),
        StampInfo(id: "flower_29", name: "藤影低垂", imageName: "FlowerStamp29",
                  description: "xxxx 年 x 月 x 日，一串花把春天轻轻垂了下来。\n紫色从高处缓缓落下，像风里一段很长很长的低语，也像时光在枝头织出的柔软流苏。"),
        StampInfo(id: "flower_30", name: "茉香留白", imageName: "FlowerStamp30",
                  description: "xxxx 年 x 月 x 日，香气先于目光停留了下来。\n几朵小小的白花安静地开在枝头，把盛夏写得清淡、洁净，又带着一点若有若无的甜。"),
        StampInfo(id: "flower_31", name: "铃语初夏", imageName: "FlowerStamp31",
                  description: "xxxx 年 x 月 x 日，初夏把铃声藏进了一朵小花里。\n一颗颗白色花盏垂落下来，像风一吹就会轻轻响起的回声，细小、纯净，又带着一种不肯打扰谁的温柔。"),
        StampInfo(id: "flower_32", name: "云团成色", imageName: "FlowerStamp32",
                  description: "xxxx 年 x 月 x 日，天光在花瓣上慢慢积成了一团云。\n蓝色、淡紫和乳白彼此依偎，像一段被轻轻收拢的潮湿心绪。"),
        StampInfo(id: "flower_33", name: "荷心映日", imageName: "FlowerStamp33",
                  description: "xxxx 年 x 月 x 日，水面把一朵花稳稳托了起来。\n粉色花瓣向四周舒展开来，连同盛夏的光，也一起落进了湖面的倒影里。"),
        StampInfo(id: "flower_34", name: "向光而生", imageName: "FlowerStamp34",
                  description: "xxxx 年 x 月 x 日，一朵花把整个夏天都朝向了光。\n金黄色的花瓣层层展开，像把积攒很久的明亮一下子托了出来，热烈、饱满，又带着一种很直白的勇气。"),
        StampInfo(id: "flower_35", name: "紫雾轻眠", imageName: "FlowerStamp35",
                  description: "xxxx 年 x 月 x 日，风把一小束安静吹成了梦。\n细细的紫色花穗立在空气里，像黄昏缓慢下沉的一次呼吸。"),
        StampInfo(id: "flower_36", name: "桂影藏香", imageName: "FlowerStamp36",
                  description: "xxxx 年 x 月 x 日，秋天把香气轻轻系在了枝头。\n那些细小的金色花朵散落在叶间，像一些悄悄亮起来的微光。"),
        StampInfo(id: "flower_37", name: "菊色成秋", imageName: "FlowerStamp37",
                  description: "xxxx 年 x 月 x 日，一朵花把秋天开得层层分明。\n金黄色的花瓣一圈圈舒展开来，像把时光慢慢收拢，又轻轻托住，带着成熟之后才有的稳和静。"),
        StampInfo(id: "flower_38", name: "虞色流火", imageName: "FlowerStamp38",
                  description: "xxxx 年 x 月 x 日，炽烈的红在风里轻轻举了起来。\n花瓣薄得像光，边缘却带着鲜明而柔韧的力量，像一瞬间被看见的热望。")
    ]

    static let childhoodStamps: [StampInfo] = [
        StampInfo(id: "ch_39", name: "灯火童年", imageName: "ChildhoodStamp39",
                  description: "xxxx 年 x 月 x 日，夜色被一盏小灯轻轻接住。\n火苗在玻璃罩里安静摇晃，把桌角、墙面和手边的影子都照得很柔和。"),
        StampInfo(id: "ch_40", name: "骑风而行", imageName: "ChildhoodStamp40",
                  description: "xxxx 年 x 月 x 日，风从车轮旁边一路追了过去。\n你踩着踏板穿过巷口，影子斜斜地落在地上，连黄昏都显得轻快起来。"),
        StampInfo(id: "ch_41", name: "掌心小兽", imageName: "ChildhoodStamp41",
                  description: "xxxx 年 x 月 x 日，一只小小的玩具住进了掌心。\n它不会真的爬远，却陪你度过了很长很长的午后。"),
        StampInfo(id: "ch_42", name: "旋转时光", imageName: "ChildhoodStamp42",
                  description: "xxxx 年 x 月 x 日，时间在地上转出了一圈小小的风。\n线一抽，陀螺便稳稳立住，把四周的目光也一起卷进旋转里。"),
        StampInfo(id: "ch_43", name: "折纸远航", imageName: "ChildhoodStamp43",
                  description: "xxxx 年 x 月 x 日，一张纸有了飞向远方的形状。\n指尖压出的每一道折痕，都像替心事找好了方向，让一张平平无奇的纸，忽然拥有了天空。"),
        StampInfo(id: "ch_44", name: "琉璃旧梦", imageName: "ChildhoodStamp44",
                  description: "xxxx 年 x 月 x 日，光在一颗小小的弹珠里打了个转。\n透明的颜色映着天光，也映着蹲在地上的目光与笑声。"),
        StampInfo(id: "ch_45", name: "风起蜻蜓", imageName: "ChildhoodStamp45",
                  description: "xxxx 年 x 月 x 日，手一松，夏天就跟着飞了起来。\n竹片旋转着升空，风也在那一刻变得看得见、摸得着。"),
        StampInfo(id: "ch_46", name: "甜夏一支", imageName: "ChildhoodStamp46",
                  description: "xxxx 年 x 月 x 日，暑气在第一口冰凉里慢慢融化。\n冰棍握在手里，带着一点甜，一点凉，还有太阳晒过午后的气味。"),
        StampInfo(id: "ch_47", name: "悠悠时刻", imageName: "ChildhoodStamp47",
                  description: "xxxx 年 x 月 x 日，一收一放之间，快乐也有了节奏。\n细线牵着圆圆的小球，上下翻飞，像把无聊的时间全都变得灵巧起来。"),
        StampInfo(id: "ch_48", name: "羽落之间", imageName: "ChildhoodStamp48",
                  description: "xxxx 年 x 月 x 日，几片羽毛把课间踢得轻快起来。\n它忽上忽下，落点总带着一点紧张和一点笑声。"),
        StampInfo(id: "ch_49", name: "收藏秘密", imageName: "ChildhoodStamp49",
                  description: "xxxx 年 x 月 x 日，小小的一页纸藏下了许多喜欢。\n星星、花朵、小动物和亮晶晶的图案，被一张张贴进本子里。"),
        StampInfo(id: "ch_50", name: "倒带时光", imageName: "ChildhoodStamp50",
                  description: "xxxx 年 x 月 x 日，声音被安静地卷进了一盘磁带里。\n耳机贴近耳边，故事、旋律和一个漫长下午都慢慢流出来。")
    ]

    /// 全部系列
    static let allSeries: [StampSeriesData] = [
        StampSeriesData(name: "人生中点", subtitle: "在抵达之前，先认出自己。",
                        stamps: midpointStamps, collectedCount: 4),
        StampSeriesData(name: "鎏金时刻", subtitle: "把岁月打工一枚善待你的。",
                        stamps: goldStamps, collectedCount: 2),
        StampSeriesData(name: "候鸟归家", subtitle: "所有远方，终将发出召唤。",
                        stamps: migrationStamps, collectedCount: 3),
        StampSeriesData(name: "四时之花", subtitle: "见到四时，心有草木。",
                        stamps: flowerStamps, collectedCount: 1),
        StampSeriesData(name: "童年", subtitle: "做小朋友的光芒，是盛大的坦荡。",
                        stamps: childhoodStamps, collectedCount: 0),
    ]

    static var totalCollected: Int {
        allSeries.reduce(0) { $0 + $1.collectedCount }
    }
}
