# Import packages
import pandas as pd
from os import listdir



# Import matches
matches = [match for match in listdir('../data') if 'matches' in match]
points = [point for point in listdir('../data') if 'points' in point]
match_dates = pd.read_csv('./match_date.csv')

# Import ATP
atp_rankings_df = pd.read_csv('./atp_rankings_10s.csv', index_col=False, names=['ranking_date', 'ranking', 'player_id', 'ranking_points'])
atp_rankings_df['player_id'] = atp_rankings_df['player_id'].fillna(-1).astype(int)
atp_players_df = pd.read_csv('./atp_players.csv', encoding='ISO-8859-1', names=['player_id', 'first_name', 'last_name', 'hand', 'birth_date', 'country_code'])
atp_players_df['full_name'] = atp_players_df['first_name'] + ' ' + atp_players_df['last_name']
atp_players_df['birth_date'] = atp_players_df['birth_date'].fillna(-1).astype(int)

# Import WTA
wta_rankings_df = pd.read_csv('./wta_rankings_10s.csv', index_col=False, names=['ranking_date', 'ranking', 'player_id', 'ranking_points'])
wta_rankings_df['player_id'] = wta_rankings_df['player_id'].fillna(-1).astype(int)
wta_players_df = pd.read_csv('./wta_players.csv', encoding='ISO-8859-1', names=['player_id', 'first_name', 'last_name', 'hand', 'birth_date', 'country_code'])
wta_players_df['full_name'] = wta_players_df['first_name'] + ' ' + wta_players_df['last_name']
wta_players_df['birth_date'] = wta_players_df['birth_date'].fillna(-1).astype(int)

# for each tournament
for slam in matches:
    matches_df = pd.read_csv('../data/' + slam)
    open_id = slam.replace('-matches.csv', '')
    open_date = match_dates[match_dates['open_id'] == open_id]['start_date'].values[0]
    # go through matches in tourname
    for index, match in matches_df.iterrows():
        playerA_name = match['player1']
        playerB_name = match['player2']

        if pd.isnull(playerA_name) or pd.isnull(playerB_name):
            continue

        if match['match_num'] < 2000:
            playerA_row = atp_players_df[atp_players_df['full_name'].isin([playerA_name])]
            playerB_row = atp_players_df[atp_players_df['full_name'].isin([playerB_name])]

            if len(playerA_row) == 0 or len(playerB_row) == 0:
                continue
            else:
                playerA_id = playerA_row['player_id'].values[0]
                playerB_id = playerB_row['player_id'].values[0]

                # get rank of a player
                playerA_ranks = atp_rankings_df[(atp_rankings_df['player_id'].isin([playerA_id])) &
                                               (atp_rankings_df['ranking_date'] < open_date)]
                playerB_ranks = atp_rankings_df[(atp_rankings_df['player_id'].isin([playerB_id])) &
                                              (atp_rankings_df['ranking_date'] < open_date)]

                if len(playerA_ranks) > 0 and len(playerB_ranks) > 0:
                    playerA_rank = playerA_ranks.tail(1)['ranking'].values[0]
                    playerB_rank = playerB_ranks.tail(1)['ranking'].values[0]

                    # add most recent rank to dataframe
                    matches_df.loc[index, 'player1_rank'] = playerA_rank.astype(int)
                    matches_df.loc[index, 'player2_rank'] = playerB_rank.astype(int)

                    # output csv file
                    matches_df.to_csv('./modifiedData/' + slam)
        else:
            playerA_row = wta_players_df[wta_players_df['full_name'].isin([playerA_name])]
            playerB_row = wta_players_df[wta_players_df['full_name'].isin([playerB_name])]

            if len(playerA_row) == 0 or len(playerB_row) == 0:
                continue
            else:
                playerA_id = playerA_row['player_id'].values[0]
                playerB_id = playerB_row['player_id'].values[0]

                playerA_ranks = wta_rankings_df[(wta_rankings_df['player_id'].isin([playerA_id])) &
                                               (wta_rankings_df['ranking_date'] < open_date)]
                playerB_ranks = wta_rankings_df[(wta_rankings_df['player_id'].isin([playerB_id])) &
                                               (wta_rankings_df['ranking_date'] < open_date)]

                if len(playerA_ranks) > 0 and len(playerB_ranks) > 0:
                    playerA_rank = playerA_ranks.tail(1)['ranking'].values[0]
                    playerB_rank = playerB_ranks.tail(1)['ranking'].values[0]

                    matches_df.loc[index, 'player1_rank'] = playerA_rank.astype(int)
                    matches_df.loc[index, 'player2_rank'] = playerB_rank.astype(int)

                    matches_df.to_csv('./modifiedData/' + slam)


print('completed')