require 'csv'
require 'rest-client'
require 'json'
require 'pry'

GAME_ID = ARGV[0]

def search_for_hits(board)
  hits = []
  board.each_with_index do |row, y|
    row.each_with_index do |col, x|
      if col
        hits << [x, y]
      end
    end
  end
  return hits
end

def search_around(board, hits)
  moves = []

  hits.each do |hit|
    x, y = hit

    if  (y > 0 && board[y - 1][x]) || (y < 9 && board[y + 1][x]) || (x < 9 && board[y][x + 1]) || (x > 0 && board[y][x - 1])
      if y > 0 && board[y - 1][x] == nil
        if y < 9 && board[y + 1][x]
          return [[x, y - 1]]
        end
      end

      if y < 9 && board[y + 1][x] == nil
        if y > 0 && board[y - 1][x]
          return [[x, y + 1]]
        end
      end

      if x > 0 && board[y][x - 1] == nil
        if x < 9 && board[y][x + 1]
          return [[x - 1, y]]
        end
      end

      if x < 9 && board[y][x + 1] == nil
        if x > 0 && board[y][x - 1]
          return [[x + 1, y]]
        end
      end

    else
      if y > 0 && board[y - 1][x] == nil
        moves.push([x, y - 1])
      end

      if y < 9 && board[y + 1][x] == nil
        moves.push([x, y + 1])
      end

      if x > 0 && board[y][x - 1] == nil
        moves.push([x - 1, y])
      end

      if x < 9 && board[y][x + 1] == nil
        moves.push([x + 1, y])
      end
    end
  end
  return moves
end

def checkerboard(board)
  results = []
  board.each_with_index do |row, y|
    row.each_with_index do |col, x|
      if board[y][x].nil? && x % 2 == y % 2
        results << [x, y]
      end
    end
  end
  return results
end

def spaces(board)
  results = []
  board.each_with_index do |row, y|
    row.each_with_index do |col, x|
      if board[y][x].nil?
        results << [x, y]
      end
    end
  end
  return results
end

def make_move(board, token)
  col = "ABCDEFGHIJ"

  hits = search_for_hits(board)
  moves = search_around(board, hits)

  x = rand(10)
  y = rand(10)

  if !moves.empty?
    x,y = moves[0]
  elsif !checkerboard(board).empty?
    x,y = checkerboard(board).sample
    # while board[y][x] != nil || !(x % 2 == y % 2)
    #   x = rand(10)
    #   y = rand(10)
    # end
  else
    x,y = spaces(board).sample
  end


  pos = "#{col[x]}#{y + 1}"
  payload = {"position": pos}
  puts "Pos: #{pos}"
  response = RestClient.post("http://battleship-smackdown.club/api/games/#{GAME_ID}/moves", payload.to_json, {content_type: 'application/json', 'X-Auth': token})
  parsed = JSON.parse(response)
  board = parsed["players"][0]["board"]
  state = parsed["state"]
  puts "board: #{board}"
  puts parsed["state"]

  return board, state
end

# Gets the game
def join_game
  b1 = {"carrier": {"position": "C5", direction: "horizontal"}, "battleship": {"position": "E8", "direction": "horizontal"}, "cruiser": {"position": "H2", "direction": "vertical"}, "submarine": {"position": "B2", "direction": "vertical"}, "destroyer": {"position": "G9", "direction": "horizontal"}}
  b2 = {"carrier": {"position": "J5", direction: "vertical"}, "battleship": {"position": "B1", "direction": "horizontal"}, "cruiser": {"position": "C5", "direction": "vertical"}, "submarine": {"position": "I2", "direction": "vertical"}, "destroyer": {"position": "A10", "direction": "horizontal"}}
  b3 = {"carrier": {"position": "A1", direction: "horizontal"}, "battleship": {"position": "B6", "direction": "horizontal"}, "cruiser": {"position": "C7", "direction": "vertical"}, "submarine": {"position": "H7", "direction": "horizontal"}, "destroyer": {"position": "F4", "direction": "horizontal"}}
  b4 = {"carrier": {"position": "B2", direction: "vertical"}, "battleship": {"position": "G9", "direction": "horizontal"}, "cruiser": {"position": "A10", "direction": "horizontal"}, "submarine": {"position": "J1", "direction": "vertical"}, "destroyer": {"position": "I4", "direction": "horizontal"}}

  ships = [b1, b2, b3, b4]


  payload = {"name": "Kristi", "board": ships.sample}
  response = RestClient.post("http://battleship-smackdown.club/api/games/#{GAME_ID}/players", payload.to_json, {content_type: 'application/json'})
  parsed = JSON.parse(response)

  token = parsed["currentPlayer"]["token"]
  board = parsed["currentPlayer"]["board"]
  state = parsed["state"]
  return token, board, state
end

token, board, state = join_game

while state != "DONE"
  board, state = make_move(board, token)
end

puts "Game is over"


=begin

response = RestClient.post("#{account_url}/api/author/course_templates", payload, headers)
parsed = JSON.parse(response)
RestClient.get("#{account_url}/api/author/roles", headers)


{"id":8,"players":[],"state":"CREATED","currentPlayer":null,"winner":null,"createdAt":"2019-08-09T16:19:37.147451Z","wonAt":null}
=end
