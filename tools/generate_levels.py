"""Rebuild the 200 editable campaign Resources from stable design patterns.
No runtime generation: each checked-in .tres can be adjusted in Godot.
"""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
WORLD_NAMES = ['Crystal Cove','Bubblegum Bay','Sunbeam Gardens','Amethyst Forest','Cloudberry Peaks','Moonstone Lagoon','Coral Carnival','Starlight Palace','Aurora Falls','Prism Summit']
NAMES = ['First light','Little treasures','Ripple effect','Crystal wishes','A bright idea','Hidden sparkle','Lucky lagoon','Jewel dance','Sunlit trail','Crown jewel','Glimmer grove','Shimmer steps','Secret garden','Rainbow ripple','Brilliant bloom','Treasure tide','Twinkle trail','Crystal chorus','One more sparkle','Island finale']
for n in range(1,201):
 world=(n-1)//20; step=(n-1)%20; hard=n%10==0
 holes=[]
 if n>=31 and step%4==1: holes=[0,7,56,63]
 if n>=61 and step%4==2: holes=[0,1,6,7,56,57,62,63]
 if n>=101 and step%4==3: holes=[0,7,8,15,48,55,56,63]
 stones=[]
 if n>=41 and step%3!=0:
  patterns=[[18,21,42,45],[26,29,34,37],[17,22,41,46,50,53],[10,13,26,29,42,45]]
  stones=patterns[(n+world)%4][:4+2*(world>=5)]
 ice=[]
 if n>=11 and step%3!=1:
  eligible=[i for i in range(9,55) if i not in stones+holes and (i//8+i%8+n)%2==0]
  count=min(len(eligible),6+world+(4 if hard else 0))
  ice=eligible[:count]
 collect = n>=4 and (step%3==1 or world>=3 and step%3==2)
 goal = (12+world*2+(4 if hard else 0)) if collect else 0
 score = (1200+world*190+step*22+(400 if hard else 0)) if not collect and not ice or step%5==4 else 0
 if n<=3: score=900+n*300
 moves=30-min(world//3,3)-(3 if hard else 0)
 if n<=3: moves=24
 tip='Match 3 gems to collect them. Reach every goal before your moves run out.'
 if n==2: tip='Match 4 in a row to make a beam gem. Match it to clear a whole line!'
 if n==3: tip='Match 5 in a line to make a Prism. Swap it with any gem to clear that color.'
 if n==4: tip='Collect the requested gem color. Other matches can help set up a cascade.'
 if ice: tip='Match gems over frosty tiles to melt the ice. Every frosty tile counts!'
 if stones: tip='Match next to stones to break them. New gems will fill the cleared spaces.'
 if n%10==0: tip='A crown challenge! Combine two special gems for a powerful blast.'
 fields={'number':n,'title':NAMES[step], 'world':world,'difficulty':'Crown' if hard else ('Tricky' if world>=3 and step%3==2 else 'Sweet'),'seed_value':1777+n*104729,'colors':5 if n<81 else 6,'moves':moves,'score_goal':score,'collect_color':(n+world)% (5 if n<81 else 6) if collect else -1,'collect_goal':goal,'ice_cells':ice,'stone_cells':stones,'void_cells':holes,'tip':tip}
 text='[gd_resource type="Resource" script_class="LevelData" load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://scripts/core/level_data.gd" id="1"]\n\n[resource]\nscript = ExtResource("1")\n'
 for k,v in fields.items():
  if isinstance(v,list): s='PackedInt32Array('+', '.join(map(str,v))+')'
  elif isinstance(v,str): s='"'+v+'"'
  else: s=str(v)
  text+=f'{k} = {s}\n'
 (ROOT/'resources/levels'/f'level_{n:03}.tres').write_text(text)
print('Wrote 200 editable levels across 10 worlds.')
