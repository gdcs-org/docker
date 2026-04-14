from firebolt import FireboltApp, service, get_param, command, set_param

@service(namespace="Device.Greeter.")
class Greeter:
    async def on_start(self):
        self._message = "Hello world!"

    @get_param("Message")
    async def get_message(self) -> str:
        return self._message
    
    @set_param("Message")
    async def set_message(self, value: str):
        self._message = value

    @command("Greet()", input={"Name": str}, output={"Greeting": str})
    async def greet(self, Name: str) -> str:
        return {"Greeting": f"{self._message}, {Name}!"}

app = FireboltApp(name="greeter")
app.register(Greeter)
app.run()