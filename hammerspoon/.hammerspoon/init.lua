-- Custom
window_original_frames = {}

-- =======================================================
-- ==   窗口管理：Command + 方向键上 = 最大化窗口    ==
-- ==   (基础版 - 会覆盖系统默认功能)               ==
-- =======================================================

local hyper = {"ctrl", "cmd"} -- 定义修饰键为 Command

-- ====================================================================
-- 绑定 Command + Up: 最大化窗口，并【存储】它之前的大小
-- ====================================================================
hs.hotkey.bind("cmd", "Up", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local win_id = win:id()

    -- 只有当这个窗口的原始状态【没有】被存储时，才执行操作。
    -- 这可以防止你连续按 Up 键时，把最大化的状态错误地存为“原始状态”。
    if not window_original_frames[win_id] then
        -- 存储当前 frame
        window_original_frames[win_id] = win:frame()
        -- 最大化窗口
        win:maximize()
    else
        -- 如果状态已经被存储，说明窗口可能已经是最大化的了。
        -- 我们可以选择直接最大化，确保它回到最大化状态。
        win:maximize()
    end
end)

-- ====================================================================
-- 绑定 Command + Down: 【恢复】窗口到它被最大化之前的大小
-- ====================================================================
hs.hotkey.bind("cmd", "Down", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local win_id = win:id()
    local original_frame = window_original_frames[win_id]

    -- 如果我们找到了这个窗口之前存储的 frame
    if original_frame then
        -- 恢复窗口
        win:setFrame(original_frame)
        -- 【重要】恢复之后，清除存储的记录。
        -- 这样，下次按 Up 键时就可以重新存储新的“原始状态”。
        window_original_frames[win_id] = nil
    end
end)

-- Command + Left: 动画移动到左半边
hs.hotkey.bind("cmd", "Left", function()
    local win = hs.window.focusedWindow()
    if win then
       win:move(hs.layout.left50)
    end
end)

-- Command + Right: 动画移动到右半边
hs.hotkey.bind("cmd", "Right", function()
    local win = hs.window.focusedWindow()
    if win then
       win:move(hs.layout.right50)
    end
end)

-- Reloading
hs.hotkey.bind(hyper, 'R', function() hs.reload() end)
hs.alert.show('Config loaded')
