defmodule DemoWeb.WeatherLive.GrandChild do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <hr>
    <p>Grandchild Liveview</p>
    """
  end
end

defmodule DemoWeb.WeatherLive.Child do
  use Phoenix.LiveView

  def mount(_, _, socket) do
    {:ok, assign(socket, display: false)}
  end

  def render(assigns) do
    ~L"""
    <p>Child Liveview</p>
    <a href="#" phx-click="toggle_liveview">Toggle Grandchild Liveview</a>
    <p>display: <%= @display %></p>
    <%= if @display do %>
    <%= live_render(@socket, DemoWeb.WeatherLive.GrandChild, id: :grandchild) %>
    <% end %>
    """
  end

  def handle_event("toggle_liveview", _, socket) do
    IO.puts("toggle_liveview")
    {:noreply, update(socket, :display, fn state -> !state end)}
  end
end

defmodule DemoWeb.WeatherLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <form phx-submit="set-location">
        <input name="location" placeholder="Location" value="<%= @location %>"/>
        <%= @weather %>
      </form>
    </div>
    <hr>
    <a href="#" phx-click="toggle_liveview">Toggle Child Liveview</a>
    <p>display: <%= @display %></p>
    <%= if @display do %>
    <%= live_render(@socket, DemoWeb.WeatherLive.Child, id: :child) %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    send(self(), {:put, "Austin"})
    {:ok, assign(socket, location: nil, weather: "...", display: false)}
  end

  def handle_event("set-location", %{"location" => location}, socket) do
    {:noreply, put_location(socket, location)}
  end

  def handle_event("toggle_liveview", _, socket) do
    {:noreply, update(socket, :display, fn state -> !state end)}
  end

  def handle_info({:put, location}, socket) do
    {:noreply, put_location(socket, location)}
  end

  defp put_location(socket, location) do
    assign(socket, location: location, weather: weather(location))
  end

  defp weather(local) do
    {:ok, {{_, 200, _}, _, body}} =
      :httpc.request(:get, {~c"http://wttr.in/#{URI.encode(local)}?format=1", []}, [], [])
    IO.iodata_to_binary(body)
  end
end
