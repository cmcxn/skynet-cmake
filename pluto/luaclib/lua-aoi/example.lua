--[[
    lua-aoi 使用示例
    
    本示例展示了 lua-aoi 模块的基本用法和常见场景
]]

local aoi = require "aoi"

-- 常量定义
local MODE_WATCHER = 1  -- 观察者
local MODE_MARKER = 2   -- 标记者
local MODE_BOTH = 3     -- 两者都是

local EVENT_ENTER = 1   -- 进入事件
local EVENT_LEAVE = 2   -- 离开事件

print("=== lua-aoi 使用示例 ===\n")

--[[
    示例 1: 创建 AOI 实例
]]
print("示例 1: 创建 AOI 实例")
print("-" .. string.rep("-", 50))

-- 创建一个从 (0,0) 开始，大小为 1000x1000，网格大小为 100 的 AOI
local aoiMgr = aoi.new(0, 0, 1000, 100)
print("创建 AOI 成功: 地图范围 (0,0) 到 (1000,1000)，网格大小 100x100")
print()

--[[
    示例 2: 插入对象
]]
print("示例 2: 插入不同类型的对象")
print("-" .. string.rep("-", 50))

-- 插入一个观察者（玩家）
local player1 = 1001
local success = aoiMgr:insert(player1, 500, 500, 200, 200, 0, MODE_WATCHER)
print(string.format("插入观察者 (玩家%d): 位置(500,500), 视野200x200, 结果: %s", 
    player1, success and "成功" or "失败"))

-- 插入几个标记者（怪物）
local monster1 = 2001
local monster2 = 2002
local monster3 = 2003

aoiMgr:insert(monster1, 550, 550, 0, 0, 0, MODE_MARKER)
print(string.format("插入标记者 (怪物%d): 位置(550,550)", monster1))

aoiMgr:insert(monster2, 450, 450, 0, 0, 0, MODE_MARKER)
print(string.format("插入标记者 (怪物%d): 位置(450,450)", monster2))

aoiMgr:insert(monster3, 800, 800, 0, 0, 0, MODE_MARKER)
print(string.format("插入标记者 (怪物%d): 位置(800,800) [视野外]", monster3))
print()

--[[
    示例 3: 处理进入事件
]]
print("示例 3: 获取并处理事件")
print("-" .. string.rep("-", 50))

local events = {}
local count = aoiMgr:update_event(events)
if count then
    print(string.format("收到 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        if event_type == EVENT_ENTER then
            print(string.format("  [进入] 观察者%d 看到了 标记者%d", watcher, marker))
        elseif event_type == EVENT_LEAVE then
            print(string.format("  [离开] 观察者%d 失去了 标记者%d", watcher, marker))
        end
    end
else
    print("没有收到事件")
end
print()

--[[
    示例 4: 查询区域内的对象
]]
print("示例 4: 查询指定区域内的对象")
print("-" .. string.rep("-", 50))

local query_result = {}
local found = aoiMgr:query(500, 500, 300, 300, query_result)
if found then
    print(string.format("在区域 (500,500) 范围 300x300 内找到 %d 个对象:", found))
    for i = 1, found do
        print(string.format("  - 对象 ID: %d", query_result[i]))
    end
else
    print("查询区域内没有对象")
end
print()

--[[
    示例 5: 更新对象位置
]]
print("示例 5: 更新对象位置并处理事件")
print("-" .. string.rep("-", 50))

-- 启用离开事件
aoiMgr:enable_leave_event(true)
print("已启用离开事件")

-- 将怪物1移动到视野外
print(string.format("移动怪物%d 从 (550,550) 到 (800,800)", monster1))
aoiMgr:update(monster1, 800, 800, 0, 0, 0)

-- 将怪物3移动到视野内
print(string.format("移动怪物%d 从 (800,800) 到 (520,520)", monster3))
aoiMgr:update(monster3, 520, 520, 0, 0, 0)

-- 获取事件
events = {}
count = aoiMgr:update_event(events)
if count then
    print(string.format("\n移动后产生 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        if event_type == EVENT_ENTER then
            print(string.format("  [进入] 观察者%d 看到了 标记者%d", watcher, marker))
        elseif event_type == EVENT_LEAVE then
            print(string.format("  [离开] 观察者%d 失去了 标记者%d", watcher, marker))
        end
    end
end
print()

--[[
    示例 6: 更新观察者视野
]]
print("示例 6: 更新观察者的视野范围")
print("-" .. string.rep("-", 50))

print(string.format("扩大玩家%d 的视野从 200x200 到 400x400", player1))
aoiMgr:update(player1, 500, 500, 400, 400, 0)

events = {}
count = aoiMgr:update_event(events)
if count then
    print(string.format("视野扩大后产生 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        if event_type == EVENT_ENTER then
            print(string.format("  [进入] 观察者%d 看到了 标记者%d (进入扩大的视野)", watcher, marker))
        end
    end
else
    print("视野扩大后没有新对象进入")
end
print()

--[[
    示例 7: 双向可见（玩家互相观察）
]]
print("示例 7: 多个观察者之间的互相观察")
print("-" .. string.rep("-", 50))

-- 插入另一个玩家，模式为 MODE_BOTH（既是观察者又是标记者）
local player2 = 1002
aoiMgr:insert(player2, 550, 550, 200, 200, 0, MODE_BOTH)
print(string.format("插入玩家%d: 位置(550,550), 视野200x200, 模式=BOTH", player2))

-- 将玩家1也改为 BOTH 模式（需要先删除再重新插入）
aoiMgr:erase(player1)
aoiMgr:insert(player1, 500, 500, 400, 400, 0, MODE_BOTH)
print(string.format("重新插入玩家%d: 位置(500,500), 视野400x400, 模式=BOTH", player1))

events = {}
count = aoiMgr:update_event(events)
if count then
    print(string.format("\n产生 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        if event_type == EVENT_ENTER then
            print(string.format("  [进入] 玩家%d 看到了 玩家%d", watcher, marker))
        end
    end
end
print()

--[[
    示例 8: 手动触发事件
]]
print("示例 8: 手动触发事件（例如对象状态变化）")
print("-" .. string.rep("-", 50))

-- 假设怪物2改变了状态，需要通知所有观察者
print(string.format("怪物%d 状态改变，手动触发事件", monster2))
aoiMgr:fire_event(monster2, EVENT_ENTER)

events = {}
count = aoiMgr:update_event(events)
if count then
    print(string.format("手动触发产生 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        print(string.format("  [通知] 观察者%d 收到 标记者%d 的状态变化", watcher, marker))
    end
end
print()

--[[
    示例 9: 检查对象是否存在
]]
print("示例 9: 检查对象是否存在于 AOI 中")
print("-" .. string.rep("-", 50))

print(string.format("检查玩家%d: %s", player1, aoiMgr:has(player1) and "存在" or "不存在"))
print(string.format("检查怪物%d: %s", monster1, aoiMgr:has(monster1) and "存在" or "不存在"))
print(string.format("检查不存在的对象9999: %s", aoiMgr:has(9999) and "存在" or "不存在"))
print()

--[[
    示例 10: 移除对象
]]
print("示例 10: 从 AOI 中移除对象")
print("-" .. string.rep("-", 50))

print(string.format("移除怪物%d", monster2))
aoiMgr:erase(monster2)

events = {}
count = aoiMgr:update_event(events)
if count then
    print(string.format("移除后产生 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        if event_type == EVENT_LEAVE then
            print(string.format("  [离开] 观察者%d 失去了 标记者%d (对象被移除)", watcher, marker))
        end
    end
end

print(string.format("\n再次检查怪物%d: %s", monster2, aoiMgr:has(monster2) and "存在" or "不存在"))
print()

--[[
    示例 11: 综合场景 - 模拟游戏中的视野管理
]]
print("示例 11: 综合场景 - 游戏视野管理模拟")
print("-" .. string.rep("-", 50))

-- 清空事件队列
events = {}
aoiMgr:update_event(events)

-- 模拟玩家移动
print("场景: 玩家1向右移动 100 单位")
aoiMgr:update(player1, 600, 500, 400, 400, 0)

-- 同时，玩家2也在移动
print("场景: 玩家2向左移动 50 单位")
aoiMgr:update(player2, 500, 550, 200, 200, 0)

-- 处理所有事件
events = {}
count = aoiMgr:update_event(events)
if count then
    print(string.format("\n双方移动后产生 %d 个事件:", count / 3))
    for i = 1, count, 3 do
        local watcher = events[i]
        local marker = events[i + 1]
        local event_type = events[i + 2]
        
        if event_type == EVENT_ENTER then
            print(string.format("  [进入] 玩家%d 看到了 玩家/怪物%d", watcher, marker))
        elseif event_type == EVENT_LEAVE then
            print(string.format("  [离开] 玩家%d 失去了 玩家/怪物%d", watcher, marker))
        end
    end
end
print()

--[[
    示例 12: 性能测试 - 批量插入和查询
]]
print("示例 12: 性能测试 - 批量操作")
print("-" .. string.rep("-", 50))

-- 创建一个新的 AOI 用于测试
local testAoi = aoi.new(0, 0, 10000, 100)

-- 批量插入对象
local start_time = os.clock()
local object_count = 1000
for i = 1, object_count do
    local x = math.random(0, 9999)
    local y = math.random(0, 9999)
    testAoi:insert(10000 + i, x, y, 0, 0, 0, MODE_MARKER)
end
local insert_time = os.clock() - start_time
print(string.format("插入 %d 个对象耗时: %.3f 秒 (平均 %.6f 秒/对象)", 
    object_count, insert_time, insert_time / object_count))

-- 批量查询
start_time = os.clock()
local query_count = 100
for i = 1, query_count do
    local x = math.random(0, 9999)
    local y = math.random(0, 9999)
    local result = {}
    testAoi:query(x, y, 500, 500, result)
end
local query_time = os.clock() - start_time
print(string.format("执行 %d 次查询耗时: %.3f 秒 (平均 %.6f 秒/查询)", 
    query_count, query_time, query_time / query_count))
print()

print("=== 示例运行完成 ===")
print()
print("提示:")
print("1. 在实际应用中，应该在游戏主循环中定期调用 update_event 处理事件")
print("2. 根据游戏需求选择合适的地图大小和网格大小")
print("3. 离开事件有性能开销，如果不需要可以保持禁用")
print("4. 对于大量对象，考虑分批处理事件以避免单帧卡顿")
