

const scriptsInEvents = {

	async EventSheet1_Event2_Act1(runtime, localVars)
	{
		globalThis.game.onJoinRoom(runtime);
	},

	async EventSheet1_Event3_Act1(runtime, localVars)
	{
		globalThis.game.onJoinError(runtime);
	},

	async EventSheet1_Event4_Act1(runtime, localVars)
	{
		console.log("Left room");
	},

	async EventSheet1_Event5_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onTankAdded(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event6_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onTankChanged(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event7_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onTankRemoved(runtime, c.lastKey);
	},

	async EventSheet1_Event8_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onBulletAdded(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event9_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onBulletChanged(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event10_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onBulletRemoved(runtime, c.lastKey);
	},

	async EventSheet1_Event11_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onPickableAdded(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event12_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onPickableRemoved(runtime, c.lastKey);
	},

	async EventSheet1_Event13_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onTeamAdded(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event14_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onTeamChanged(runtime, c.lastKey, c.lastValue);
	},

	async EventSheet1_Event15_Act1(runtime, localVars)
	{
		const c = globalThis.game.getColyseus(runtime);
		globalThis.game.onWinnerChange(c.lastValue);
	},

	async EventSheet1_Event16_Act1(runtime, localVars)
	{
		globalThis.game.onTick(runtime);
	}
};

globalThis.C3.JavaScriptInEvents = scriptsInEvents;
