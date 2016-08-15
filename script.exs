defmodule Werewolf do
  use Xee.ThemeScript
  require Logger

  # Callbacks
  def script_type do
    :message
  end

  def install, do: nil

  @modes ["preparation", "morning", "evening", "night", "meeting", "result", "destroied"]
  @pages ["name", "wait", "description", "morning", "evening", "night", "meeting", "result", "destroied"]
  @roles %{villager: %{name: "村人",   isWerewolfSide: false, isWerewolf: false, description: "特殊能力はありません。現在の情報を元に推理し、村を平和に導きましょう。"},
           psychic:  %{name: "霊媒師", isWerewolfSide: false, isWerewolf: false, description: "夜に、処刑された人が人狼か否かを知ることができます。"},
           seer:     %{name: "占い師", isWerewolfSide: false, isWerewolf: false, description: "夜に、生存者を1人占うことができ、人狼か否かを知ることができます。(狂人や狩人を占っても村人と出ます。)"},
           hunter:   %{name: "狩人",   isWerewolfSide: false, isWerewolf: false, description: "夜に、生存者1人を守ることができます。狩人が守っている人を人狼が襲撃した場合、襲撃は失敗し、翌日犠牲者は発生しません。しかし、自分自身を守ることはできません。"},
           werewolf: %{name: "人狼",   isWerewolfSide: true, isWerewolf: true, description: "人の皮をかぶった狼です。夜のターンで村人を1人襲撃して食い殺し(噛み)ます。人狼は人間に対し、1対1では力で勝てますが、相手が村人2名だと勝てません。よって、人狼の数と村人の数が同数になるまで、1人づつ噛んでいきます。また、人狼が複数いる場合、他の人狼を知ることができます。"},
           minion:   %{name: "狂人",   isWerewolfSide: true, isWerewolf: false, description: "人狼側ですが、占いと霊能結果では「人狼ではない」と判定されます。人狼側が勝利することで、狂人も勝利となります。"}}

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
      resultOfDay: [%{}],
      alivePeoples: [],
      deadPeoples: [],
      host: %{},
      participants: %{},
      checkCount: 0
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
      "skip_meeting" -> skip_meeting(data)
    end
  end

  def handle_received(data, %{"action" => action} = options, id) do
    case action do
      "fetch_contents" -> fetch_contents(data, id)
      "fetch_option"   -> fetch_option(data, id)
      "set_wait"       -> set_wait(data, id)
      "set_name"       -> set_name(data, options["params"], id)
      "vote"           -> vote(data, options["params"], id)
      "ability"        -> ability(data, options["params"], id)
      "checked"        -> check(data, id)
      "result"         -> result(data, id)
    end
  end

  def fetch_contents(data) do
    action = %{
      type: "RECEIVE_CONTENTS",
      data: data,
    }
    {:ok, %{"data" => data, "host" => %{action: action}}}
  end

  def matching(data) do
    {roles, _} = data.roleCount
                  |> Enum.map_reduce([], fn {role, count}, acc -> {List.duplicate(role, count), acc} end)
    roles = roles |> List.flatten |> Enum.shuffle
    participants = Enum.shuffle(data.participants)
                    |> Enum.map_reduce(0, fn {id, participant}, acc ->
                         {{id, Map.put(participant, :role, Enum.at(roles, acc))
                                |> Map.put(:page, "role")
                                |> Map.put(:isAlive, true)
                                |> Map.put(:votes, [])
                                |> Map.put(:options, [])
                          }, acc + 1}
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
                |> Map.put(:resultOfDay,  [%{morning: %{deadPeople: "吉田"}}])
                |> Map.put(:date,         0)
                |> Map.put(:checkCount,   0)
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
      data: data,
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
            |> Map.put(:mode, "morning")
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
      data: data,
    }
    {:ok, %{"data" => data, "host" => %{action: action}}}
  end

  def skip_meeting(data) do
    participants = data.participants
                    |> Enum.map_reduce(0, fn {id, participant}, acc ->
                         {{id, Map.put(participant, :page, "evening")}, 0}
                       end)
                    |> elem(0)
                    |> Enum.into(%{})
    data = data
            |> Map.put(:mode, "evening")
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

  def fetch_contents(%{participants: participants} = data, id) do
    result = List.last(data.resultOfDay)
              |> Map.put(:players, data.participants)
    action = %{
      type: "RECEIVE_CONTENTS",
      page: participants[id].page,
      player: participants[id],
      count: data.count,
      date:  data.date,
      result: result,
      role: data.role,
      meetingTime: data.meetingTime,
      alivePeoples: data.alivePeoples,
      deadPeoples: data.deadPeoples,
      villageName: data.villageName,
      option: Enum.at(participants[id].options, data.date)
    }
    {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
  end

  def fetch_option(%{participants: participants} = data, id) do
    participant = participants[id]
    werewolfs = participants
                    |> Enum.filter(fn {id, participant} -> participant.role == :werewolf end)
                    |> Enum.map_reduce(0, fn {id, participant}, acc ->
                         {participant.name, 0}
                       end)
                    |> elem(0)
    option = case participant.role do
      :werewolf -> werewolfs
      _ -> %{}
    end
    action = %{
      type: "RECEIVE_OPTIONS",
      option: option
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
      host_action = %{
        type: "RECEIVE_PLAYERS",
        data: data
      }
      participant_action = %{
        type: "RECEIVE_CONTENTS",
        page: "wait",
        player: participants[id]
      }
      {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => %{id => %{action: participant_action}}}}
    else
      {:ok, %{"data" => data}}
    end
  end

  def vote(%{participants: participants} = data, params, id) do
    if Map.has_key?(participants, id) do
      if participants[id].isAlive do
        votes = participants[id].votes
        if Enum.count(votes) == data.date do
          participant = Map.put(participants[id], :votes, List.insert_at(votes, -1, params))
          participants = Map.put(participants, id, participant)
          data = Map.put(data, :participants, participants)
        end
        countVote =  Enum.count(participants, fn {id, participant} -> Enum.count(participant.votes) >= data.date + 1 end)
        if countVote >= Enum.count(data.alivePeoples) do
          count = Enum.reduce(data.alivePeoples, [], fn (player, acc) ->
                        List.insert_at(acc, -1, {player, Enum.count(participants, fn {id, participant} ->
                          Enum.at(participant.votes, data.date) == player
                        end)})
                      end)
                      |> Map.new
          max = Enum.max_by(count, fn {name, vote} -> vote end) |> elem(1)
          dead = Enum.filter(count, fn {name, vote} -> vote == max end)
                  |> Enum.random
                  |> elem(0)
          voteTo = Enum.filter(participants, fn {id, participant} -> participant.isAlive == true end)
                    |> Enum.reduce(%{}, fn {id, participants}, acc -> Map.put(acc, participant.name, Enum.at(participant.votes, data.date)) end)
          deadPeople = Enum.find(participants, fn {id, participant} -> participant.name == dead end)
          deadId       = deadPeople |> elem(0)
          personal     = deadPeople |> elem(1)
          participants = Map.put(participants, deadId, Map.put(personal, :isAlive, false))
          alivePeoples = List.delete(data.alivePeoples, dead)
          deadPeoples  = List.insert_at(data.deadPeoples, -1, dead)
          result = Map.merge(Enum.at(data.resultOfDay, data.date), %{
            evening: %{
              deadPeople: dead,
              votes: voteTo,
              count: count
            }
          })
          resultOfDay = List.replace_at(data.resultOfDay, data.date, result)
          data = data
                  |> Map.put(:resultOfDay, resultOfDay)
                  |> Map.put(:participants, participants)
                  |> Map.put(:alivePeoples, alivePeoples)
                  |> Map.put(:deadPeoples,  deadPeoples)
        end
        check(data, id)
      else
        action = %{
          type: "CHANGE_PAGE",
          page: "result"
        }
        {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
      end
    else
      {:ok, %{"data" => data}}
    end
  end

  # Todo
  def ability(%{participants: participants} = data, params, id) do
    case participants[id].role do
      :werewolf -> raid(data, params, id) |> check(id)
      :seer     -> data = seer(data, params, id)
                   result = List.last(data.participants[id].options)
                   action = %{
                     type: "RECEIVE_OPTIONS",
                     value: result
                   }
                   {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
      :psychic  -> data = psychic(data, params, id)
                   result = List.last(data.participants[id].options)
                   action = %{
                     type: "RECEIVE_OPTIONS",
                     value: result
                   }
                   {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
      :hunter   -> check(data, id) ## todo
      _ -> check(data, id)
    end
  end

  def raid(%{participants: participants} = data, params, id) do
    raid = participants[id].options
    if Enum.count(raid) == data.date do
      participant = Map.put(participants[id], :options, List.insert_at(raid, -1, params))
      participants = Map.put(participants, id, participant)
      data = Map.put(data, :participants, participants)
    end
    data
  end

  def seer(%{participants: participants} = data, params, id) do
    participant = participants[id]
    if participant.isAlive == true do
      if Enum.count(participant.options) <= data.date do
        personal = Enum.find(participants, fn {id, participant} -> participant.name == params and participant.isAlive == true end)
                    |> elem(1)
        isWerewolf = data.role[personal.role].isWerewolf
        participant = Map.put(participants[id], :options, List.insert_at(participant.options, -1, %{target: params, isWerewolf: isWerewolf}))
        participants = Map.put(participants, id, participant)
        data = Map.put(data, :participants, participants)
      else
        data
      end
    else
      data
    end
  end

  def psychic(%{participants: participants} = data, params, id) do
    participant = participants[id]
    if participant.isAlive == true do
      if Enum.count(participant.options) <= data.date do
        personal = Enum.find(participants, fn {id, participant} -> participant.name == params and participant.isAlive == false end)
                    |> elem(1)
        isWerewolf = data.role[personal.role].isWerewolf
        participant = Map.put(participants[id], :options, List.insert_at(participant.options, -1, %{target: params, isWerewolf: isWerewolf}))
        participants = Map.put(participants, id, participant)
        data = Map.put(data, :participants, participants)
      else
        data
      end
    else
      data
    end
  end

  def hunter(%{participants: participants} = data, params, id) do
    protection = participants[id].options
    if Enum.count(protection) == data.date do
      participant = Map.put(participants[id], :options, List.insert_at(protection, -1, params))
      participants = Map.put(participants, id, participant)
      data = Map.put(data, :participants, participants)
    end
    data
  end

  def check(%{participants: participants} = data, id) do
    if Map.has_key?(participants, id) do
      # Set wait
      participant = Map.put(participants[id], :page, "wait")
      participants = Map.put(participants, id, participant)

      # if Everyone is Ready
      if (data.checkCount + 1) >= Enum.count(data.alivePeoples) do

        if data.mode == "night" do
          # Result of Raid
          werewolfs = Enum.filter(participants, fn {id, participant} -> participant.role == :werewolf and participant.isAlive end)
          hunters = Enum.filter(participants, fn {id, participant} -> participant.role == :hunter and participant.isAlive end)
          protected = Enum.map_reduce(hunters, [], fn {id, participant}, acc -> Enum.at(participant.options, data.date) end)
          count = Enum.reduce(data.alivePeoples, [], fn (player, acc) ->
                    List.insert_at(acc, -1, {player, Enum.count(werewolfs, fn {id, participant} ->
                      Enum.at(participant.options, data.date) == player and not Enum.find_value(protected, player)
                    end)})
                  end)
                  |> Map.new
          max = Enum.max_by(count, fn {name, raid} -> raid end) |> elem(1)
          if max == 0 do
            result = %{morning: %{deadPeople: nil}}
            data = data
                  |> Map.put(:resultOfDay, List.insert_at(data.resultOfDay, -1, result))
          else
            dead = Enum.filter(count, fn {name, raid} -> raid == max end)
              |> Enum.random
              |> elem(0)
            deadPeople   = Enum.find(participants, fn {id, participant} -> participant.name == dead end)
            deadId       = deadPeople |> elem(0)
            personal     = deadPeople |> elem(1)
            participants = Map.put(participants, deadId, Map.put(personal, :isAlive, false))
            alivePeoples = List.delete(data.alivePeoples, dead)
            deadPeoples  = List.insert_at(data.deadPeoples, -1, dead)

            result = %{morning: %{deadPeople: dead}}
            data = data
                  |> Map.put(:resultOfDay, List.insert_at(data.resultOfDay, -1, result))
                  |> Map.put(:participants, participants)
                  |> Map.put(:alivePeoples, alivePeoples)
                  |> Map.put(:deadPeoples,  deadPeoples)
          end
        end

        data = change_turn(data)
        participants = data.participants
                        |> Enum.map_reduce(0, fn {id, participant}, acc ->
                             {{id, Map.put(participant, :page, data.mode)}, 0}
                           end)
                        |> elem(0)
                        |> Enum.into(%{})
        data = Map.put(data, :participants, participants)
        host_action = %{
          type: "RECEIVE_PLAYERS",
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
        end)
        {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => participant_action}}
      else
        data = Map.put(data, :participants, participants)
                |> Map.put(:checkCount, data.checkCount + 1)
        host_action = %{
          type: "RECEIVE_CONTENTS",
          data: data
        }
        participant_action = %{
          type: "RECEIVE_CONTENTS",
          page: "wait",
          player: participants[id]
        }
        {:ok, %{"data" => data, "host" => %{action: host_action}, "participant" => %{id => %{action: participant_action}}}}
      end
    else
      {:ok, %{"data" => data}}
    end
  end

  def change_turn(data) do
    mode = data.mode
    mode = case mode do
      "morning" -> "meeting"
      "meeting" -> "evening"
      "evening" -> "night"
      "night"   -> "morning"
    end
    date = if mode == "morning", do: data.date + 1, else: data.date
    state = checkGameState(data)
    if state do
      mode = "result"
      result = Map.merge(Enum.at(data.resultOfDay, data.date), %{
        isEnd: true,
        side: @roles[state].name,
        players: data.participants
      })
      data = Map.put(data, :resultOfDay, List.insert_at(data.resultOfDay, -1, result))
    end
    data = data
            |> Map.put(:mode, mode)
            |> Map.put(:checkCount, 0)
            |> Map.put(:date, date)
    data
  end

  def result(%{participants: participants} = data, id) do
    participant = participants[id]
    if participant.isAlive != true or data.mode == "result" do
      action = %{
        type: "RECEIVE_RESULT",
        result: %{
          isEnd: data.mode == "result",
          side:  nil,
          players: participants
        }
      }
    end
    {:ok, %{"data" => data, "participant" => %{id => %{action: action}}}}
  end

  def checkGameState(%{participants: participants} = data) do
    werewolf_num = participants
                    |> Enum.filter(fn {id, participant} -> data.role[participant.role].isWerewolfSide and participant.isAlive end)
                    |> Enum.count
    alivePeoples_num = Enum.count(data.alivePeoples)
    cond do
      werewolf_num == 0 -> :villager
      werewolf_num * 2 >= alivePeoples_num -> :werewolf
      true -> nil
    end
  end
end
