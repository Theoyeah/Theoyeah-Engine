--made by frantastic24, credit or i disembowel you.

local texture = 'noteSplashes' --image path goes here

function onCreate()

end

function onStartCountdown()
	if not  ClientPrefs.middleScroll then
	makeAnimatedLuaSprite('splashLeft', texture)
	makeAnimatedLuaSprite('splashDown', texture)
	makeAnimatedLuaSprite('splashUp', texture)
	makeAnimatedLuaSprite('splashRight', texture)

	for i=1, 3 do
		addAnimationByPrefix('splashLeft', 'splash' ..i, 'note splash purple ' ..i, 24, false)
		addAnimationByPrefix('splashDown', 'splash' ..i, 'note splash blue ' ..i, 24, false)
		addAnimationByPrefix('splashUp', 'splash' ..i, 'note splash green ' ..i, 24, false)
		addAnimationByPrefix('splashRight', 'splash' ..i, 'note splash red ' ..i, 24, false)
	end

	setProperty('splashLeft.alpha', 0.6)
	setProperty('splashDown.alpha', 0.6)
	setProperty('splashUp.alpha', 0.6)
	setProperty('splashRight.alpha', 0.6)

	setObjectCamera('splashLeft', 'camHUD')
	setObjectCamera('splashDown', 'camHUD')
	setObjectCamera('splashUp', 'camHUD')
	setObjectCamera('splashRight', 'camHUD')

	setProperty('splashLeft.visible', false)
	setProperty('splashDown.visible', false)
	setProperty('splashUp.visible', false)
	setProperty('splashRight.visible', false)

	setProperty('splashLeft.offset.x', 10)
	setProperty('splashLeft.offset.y', 10)
	setProperty('splashDown.offset.x', 10)
	setProperty('splashDown.offset.y', 10)
	setProperty('splashUp.offset.x', 10)
	setProperty('splashUp.offset.y', 10)
	setProperty('splashRight.offset.x', 10)
	setProperty('splashRight.offset.y', 10)

	setObjectOrder('splashLeft', getObjectOrder('grpNoteSplashes'))
	setObjectOrder('splashDown', getObjectOrder('grpNoteSplashes'))
	setObjectOrder('splashUp', getObjectOrder('grpNoteSplashes'))
	setObjectOrder('splashRight', getObjectOrder('grpNoteSplashes'))

	addLuaSprite('splashLeft')
	addLuaSprite('splashDown')
	addLuaSprite('splashUp')
	addLuaSprite('splashRight')
	return Function_Continue
end
end

function opponentNoteHit(id, dir, type, sus)
	if not  ClientPrefs.middleScroll then
	if dir == 0 and not sus then
		setProperty('splashLeft.x', getPropertyFromGroup('opponentStrums', 0, 'x')-(160*0.7)*0.95)
		setProperty('splashLeft.y', getPropertyFromGroup('opponentStrums', 0, 'y')-(160*0.7))
		setProperty('splashLeft.visible', true)
		objectPlayAnimation('splashLeft', 'splash'.. getRandomInt(1,2), true)
		setProperty('splashLeft.animation.curAnim.frameRate', 24 + getRandomInt(-2, 2))
	elseif dir == 1 and not sus  then
		setProperty('splashDown.x', getPropertyFromGroup('opponentStrums', 1, 'x')-(160*0.7)*0.95)
		setProperty('splashDown.y', getPropertyFromGroup('opponentStrums', 1, 'y')-(160*0.7))
		setProperty('splashDown.visible', true)
		objectPlayAnimation('splashDown', 'splash'.. getRandomInt(1,2), true)
		setProperty('splashDown.animation.curAnim.frameRate', 24 + getRandomInt(-2, 2))
	elseif dir == 2 and not sus then
		setProperty('splashUp.x', getPropertyFromGroup('opponentStrums', 2, 'x')-(160*0.7)*0.95)
		setProperty('splashUp.y', getPropertyFromGroup('opponentStrums', 2, 'y')-(160*0.7))
		setProperty('splashUp.visible', true)
		objectPlayAnimation('splashUp', 'splash'.. getRandomInt(1,2), true)
		setProperty('splashUp.animation.curAnim.frameRate', 24 + getRandomInt(-2, 2))
	elseif dir == 3 and not sus then
		setProperty('splashRight.x', getPropertyFromGroup('opponentStrums', 3, 'x')-(160*0.7)*0.95)
		setProperty('splashRight.y', getPropertyFromGroup('opponentStrums', 3, 'y')-(160*0.7))
		setProperty('splashRight.visible', true)
		objectPlayAnimation('splashRight', 'splash'.. getRandomInt(1,2), true)
		setProperty('splashRight.animation.curAnim.frameRate', 24 + getRandomInt(-2, 2))
	end
end
end
function onUpdate()
	if not  ClientPrefs.middleScroll then
	if getProperty('splashLeft.animation.curAnim.finished') and getProperty('splashLeft.visible') then
		setProperty('splashLeft.visible', false)
	end
	if getProperty('splashDown.animation.curAnim.finished') and getProperty('splashDown.visible') then
		setProperty('splashDown.visible', false)
	end
	if getProperty('splashUp.animation.curAnim.finished') and getProperty('splashUp.visible') then
		setProperty('splashUp.visible', false)
	end
	if getProperty('splashRight.animation.curAnim.finished') and getProperty('splashRight.visible') then
		setProperty('splashRight.visible', false)
	end
end
end