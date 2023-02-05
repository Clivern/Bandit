# Copyright 2023 Clivern. All rights reserved.
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

defmodule Bandit.Module.TeamModule do
  @moduledoc """
  Team Module
  """

  alias Bandit.Context.TeamContext
  alias Bandit.Context.UserContext
  alias Bandit.Service.ValidatorService

  @doc """
  Create a team
  """
  def create_team(data \\ %{}) do
    team =
      TeamContext.new_team(%{
        name: data[:name],
        slug: data[:slug],
        description: data[:description]
      })

    case TeamContext.create_team(team) do
      {:ok, team} ->
        {:ok, team}

      {:error, changeset} ->
        messages =
          changeset.errors()
          |> Enum.map(fn {field, {message, _options}} -> "#{field}: #{message}" end)

        {:error, Enum.at(messages, 0)}
    end
  end

  @doc """
  Sync team members
  """
  def sync_team_members(team_id, future_members \\ []) do
    current_members = []

    current_members =
      for member <- UserContext.get_team_users(team_id) do
        current_members ++ member.id
      end

    # @TODO: Track errors
    for member <- current_members do
      if member not in future_members do
        UserContext.remove_user_from_team(member, team_id)
      end
    end

    for member <- future_members do
      if member not in current_members do
        UserContext.add_user_to_team(member, team_id)
      end
    end
  end

  @doc """
  Update a team
  """
  def update_team(data \\ %{}) do
    uuid = ValidatorService.get_str(data[:uuid], "")

    team = uuid |> TeamContext.get_team_by_uuid()

    case team do
      nil ->
        {:not_found, "Team with UUID #{uuid} not found"}

      _ ->
        new_team =
          TeamContext.new_team(%{
            name: ValidatorService.get_str(data[:name], team.name),
            description: ValidatorService.get_str(data[:description], team.description),
            slug: team.slug
          })

        case TeamContext.update_team(team, new_team) do
          {:ok, team} ->
            {:ok, team}

          {:error, changeset} ->
            messages =
              changeset.errors()
              |> Enum.map(fn {field, {message, _options}} -> "#{field}: #{message}" end)

            {:error, Enum.at(messages, 0)}
        end
    end
  end

  @doc """
  Get team by an id
  """
  def get_team_by_id(id) do
    team =
      id
      |> ValidatorService.parse_int()
      |> TeamContext.get_team_by_id()

    case team do
      nil ->
        {:not_found, "Team with ID #{id} not found"}

      _ ->
        {:ok, team}
    end
  end

  @doc """
  Get team by UUID
  """
  def get_team_by_uuid(uuid) do
    uuid = ValidatorService.get_str(uuid, "")

    team = uuid |> TeamContext.get_team_by_uuid()

    case team do
      nil ->
        {:not_found, "Team with UUID #{uuid} not found"}

      _ ->
        {:ok, team}
    end
  end

  @doc """
  Get team by slug
  """
  def is_slug_used(slug) do
    slug = ValidatorService.get_str(slug, "")

    team = slug |> TeamContext.get_team_by_slug()

    case team do
      nil ->
        false

      _ ->
        true
    end
  end

  @doc """
  Count Users
  """
  def count_teams() do
    TeamContext.count_teams()
  end

  @doc """
  Get user teams
  """
  def get_user_teams(user_id) do
    UserContext.get_user_teams(user_id)
  end

  @doc """
  Get teams
  """
  def get_teams(offset, limit) do
    TeamContext.get_teams(offset, limit)
  end

  @doc """
  Delete a Team by UUID
  """
  def delete_team_by_uuid(uuid) do
    uuid = ValidatorService.get_str(uuid, "")

    team = uuid |> TeamContext.get_team_by_uuid()

    case team do
      nil ->
        {:not_found, "Team with ID #{uuid} not found"}

      _ ->
        TeamContext.delete_team(team)
        {:ok, "Team with ID #{uuid} deleted successfully"}
    end
  end

  @doc """
  Validate Team ID
  """
  def validate_team_id(id) do
    TeamContext.validate_team_id(id)
  end
end