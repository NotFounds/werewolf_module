defmodule Werewolf do
  use Xee.ThemeScript
  require Logger

  # Callbacks
  def script_type do
    :message
  end

  def install, do: nil

  @modes ["preparation", "wait", "play", "result", "destroied"]
  @pages ["name", "wait", "description", "morning", "evening", "meeting", "votes", "result", "destroied"]
  @roles %{villager: %{name: "村人",   isWerewoldSide: false, isWerewold: false, description: "特殊能力はありません。現在の情報を元に推理し、村を平和に導きましょう。"},
           psychic:  %{name: "霊媒師", isWerewoldSide: false, isWerewold: false, description: "夜に、処刑された人が人狼か否かを知ることができます。"},
           seer:     %{name: "占い師", isWerewoldSide: false, isWerewold: false, description: "夜に、生存者を1人占うことができ、人狼か否かを知ることができます。(狂人や狩人を占っても村人と出ます。)"},
           hunter:   %{name: "狩人",   isWerewoldSide: false, isWerewold: false, description: "夜に、生存者1人を守ることができます。狩人が守っている人を人狼が襲撃した場合、襲撃は失敗し、翌日犠牲者は発生しません。しかし、自分自身を守ることはできません。"},
           werewolf: %{name: "人狼",   isWerewoldSide: true, isWerewold: true, description: "人の皮をかぶった狼です。夜のターンで村人を1人襲撃して食い殺し(噛み)ます。人狼は人間に対し、1対1では力で勝てますが、相手が村人2名だと勝てません。よって、人狼の数と村人の数が同数になるまで、1人づつ噛んでいきます。また、人狼が複数いる場合、他の人狼を知ることができます。"},
           minion:   %{name: "狂人",   isWerewoldSide: true, isWerewold: false, description: "人狼側ですが、占いと霊能結果では「人狼ではない」と判定されます。人狼側が勝利することで、狂人も勝利となります。"}}

  def init do
    {:ok, %{"data" => %{
      villageName: "",
      role: @roles,
      roleCount: %{villager: 0,
                   psychic:  0,
                   seer:     0,
                   hunter:   0,
                   werewolf: 0,
                   minion:   0},
      count: 0,
      mode: "preparation",
      date: 0,
      meetingTime: 90,
      resultOfDay: [],
      alivePeoples: [],
      deadPeoples: [],
      host: %{},
      participants: %{}
    }}}
  end

  def join(%{participants: participants} = data, id) do
    if not Map.has_key?(participants, id) do
      participant = %{
        id: id,
        name: "",
        page: "name",
        role: nil,
        isAlive: true,
        votes: [],
        options: [], # Raid, Psychic, CheckRole, Revenge, etc...
        notifications: []
      }
      count = data.count + 1
      data = Map.put(data, :count, count)
      participants = Map.put(participants, id, participant)
      data = %{data | participants: participants}
      action = %{
        type: "ADD_PLAYER",
        id: id,
        participants: participants,
        count: count
      }
      {:ok, %{"data" => data, "host" => %{action: action}}}
    else
      {:ok, %{"data" => data}}
    end
  end

  def handle_received(data, %{"action" => action} = options) do
    case action do
      "fetch_contents" -> fetch_contents(data)
      "do_matching" -> matching(data)
      "set_role" -> set_role(data, options["params"])
      "start" -> start(data)
      "destroy" -> destroy(data)
      "set_villageName" -> set_name(data, options["params"])
    end
  end

  def handle_received(data, %{"action" => action} = options, id) do
    case action do
      "fetch_contents" -> fetch_contents(data, id)
      "set_wait" -> set_wait(data, id)
      "set_name" -> set_name(data, options["params"], id)
    end
  end

  def fetch_contents(data) do
    action = %{
      type: "RECEIVE_CONTENTS",
      mode: "wait",
      data: data,
      count: data.count
    }
    {:ok, %{"data" => data, "host" => %{action: action}}}
  end

  def matching(data) do
    {roles, _} = data.roleCount
                  |> Enum.map_reduce([], fn {role, count}, acc -> {List.duplicate(role, count), acc} end)
    roles = roles |> List.flatten |> Enum.shuffle
    participants = Enum.shuffle(data.participants)
                    |> Enum.map_reduce(0, fn {id, participant}, acc ->
                         {{id, Map.put(participant, :role, Enum.at(roles, acc)) |> Map.put(:page, "role")}, acc + 1}
                       end)
                    |> elem(0)
                    |> Enum.into(%{})
    alivePeoples = data.participants
                    |> Enum.map_reduce(nil, fn {id, participant}, acc ->
                         {participant.name, acc}
                       end)
                    |> elem(0)
    data = data |> Map.put(:participants, participants)
                |> Map.put(:alivePeoples, alivePeoples)
                |> Map.put(:deadPeoples,  [])
                |> Map.put(:resultOfDay,  [%{morning: %{deadPeople: "マサハル"}}])
                |> Map.put(:date,         0)
    host_action = %{
      type: "RECEIVE_PLAYERS",
      data: data
    }
    participant_action = Enum.map(participants, fn {id, player} ->
      {id, %{
        action: %{
          type: "RECEIVE_CONTENTS",
          page: player.page,
        player: player,
          role: data.role
      }}}
    end) |> Enum.into(%{})
    {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => participant_action}}
  end

  def set_role(data, params) do
    roleCount = params
                |> Enum.map_reduce(%{}, fn {role, count}, acc -> {nil, Map.put(acc, String.to_atom(role), count)} end)
                |> elem(1)
    data = Map.put(data, :roleCount, roleCount)
    action = %{
      type: "RECEIVE_CONTENTS",
      mode: data.mode,
      data: data,
      count: data.count
    }
    {:ok, %{"data" => data, "host" => %{action: action}}}
  end

  def start(data) do
    participants = data.participants
                    |> Enum.map_reduce(0, fn {id, participant}, acc ->
                         {{id, Map.put(participant, :page, "morning")}, 0}
                       end)
                    |> elem(0)
                    |> Enum.into(%{})
    data = data
            |> Map.put(:mode, "play")
            |> Map.put(:participants, participants)
    host_action = %{
      type: "CHANGE_MODE",
      mode: data.mode,
      data: data
    }
    participant_action = Enum.map(participants, fn {id, player} ->
      {id, %{
        action: %{
          type: "UPDATE_TURN",
          page: player.page,
        player: player,
          date: data.date,
        result: List.last(data.resultOfDay),
          role: data.role,
  alivePeoples: data.alivePeoples,
   deadPeoples: data.deadPeoples
      }}}
    end) |> Enum.into(%{})
    {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => participant_action}}
  end

  def destroy(data) do
    participants = data.participants
                    |> Enum.map_reduce(0, fn {id, participant}, acc ->
                         {{id, Map.put(participant, :page, "destroied")}, 0}
                       end)
                    |> elem(0)
                    |> Enum.into(%{})
    data = data
            |> Map.put(:mode, "destroied")
            |> Map.put(:participants, participants)
    host_action = %{
      type: "CHANGE_MODE",
      mode: data.mode,
      data: data
    }
    participant_action = Enum.map(participants, fn {id, player} ->
      {id, %{
        action: %{
          type: "CHANGE_PAGE",
          page: player.page
      }}}
    end) |> Enum.into(%{})
    {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => participant_action}}
  end

  def set_name(data, params) do
    data = Map.put(data, :villageName, params)
    action = %{
      type: "RECEIVE_CONTENTS",
      mode: data.mode,
      data: data,
      count: data.count
    }
    {:ok, %{"data" => data, "host" => %{action: action}}}
  end

  def fetch_contents(%{participants: participants} = data, id) do
    action = %{
      type: "RECEIVE_CONTENTS",
      page: participants[id].page,
      player: participants[id],
      count: data.count,
      date:  data.date,
      result: List.last(data.resultOfDay),
      role: data.role,
      meetingTime: data.meetingTime,
      alivePeoples: data.alivePeoples,
      deadPeoples: data.deadPeoples,
      villageName: data.villageName
    }
    {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
  end

  def set_name(%{participants: participants} = data, name, id) do
    if Map.has_key?(participants, id) do
      participant  = Map.put(participants[id], :name, name)
                     |> Map.put(:page, "description")
      participants = Map.put(participants, id, participant)
      data = Map.put(data, :participants, participants)
      host_action = %{
        type: "RECEIVE_PLAYERS",
        data: data
      }
      participant_action = %{
        type: "RECEIVE_CONTENTS",
        page: "description",
        player: participant
      }
      {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => %{id => %{action: participant_action}}}}
    else
      {:ok, %{"data" => data}}
    end
  end

  def set_wait(%{participants: participants} = data, id) do
    if Map.has_key?(participants, id) do
      participant  = Map.put(participants[id], :page, "wait")
      participants = Map.put(participants, id, participant)
      data = Map.put(data, :participants, participants)
      action = %{
        type: "RECEIVE_CONTENTS",
        page: "wait",
        player: participants[id]
      }
      {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
    else
      {:ok, %{"data" => data}}
    end
  end
end
