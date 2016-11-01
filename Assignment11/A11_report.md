#Assignment 11: Performance and Tuning

##Machine Information
|     |                           |
|-----|--------------------------:|
| OS  | VMWARE through Windows 10 |
| CPU |        Intel Core i5-2500 |
| RAM |                      8 GB |
| SSD |           Samsung 840 EVO |
| GPU |         AMD Radeon RX 480 |

##Part I
| Command | Time            |
|---------|-----------------|
| FILL    | 00:00:26.121487 |

###Query results
####Query 1
                                                                QUERY PLAN                                                            
    ----------------------------------------------------------------------------------------------------------------------------------
     Aggregate  (cost=11190.64..11190.65 rows=1 width=0) (actual time=76.662..76.662 rows=1 loops=1)
       Output: count(*)
       Buffers: shared hit=2569
       ->  Nested Loop  (cost=0.00..10596.12 rows=237807 width=0) (actual time=0.018..71.603 rows=80465 loops=1)
             Buffers: shared hit=2569
             ->  Seq Scan on public.results r  (cost=0.00..7607.15 rows=79269 width=4) (actual time=0.008..46.641 rows=80465 loops=1)
                   Output: r.peopleid, r.competitionid, r.sportid, r.result
                   Filter: (r.sportid = 4)
                   Rows Removed by Filter: 322667
                   Buffers: shared hit=2568
             ->  Materialize  (cost=0.00..16.39 rows=3 width=4) (actual time=0.000..0.000 rows=1 loops=80465)
                   Output: s.id
                   Buffers: shared hit=1
                   ->  Seq Scan on public.sports s  (cost=0.00..16.38 rows=3 width=4) (actual time=0.003..0.003 rows=1 loops=1)
                         Output: s.id
                         Filter: (s.id = 4)
                         Rows Removed by Filter: 5
                         Buffers: shared hit=1
     Planning time: 0.145 ms
     Execution time: 76.737 ms
    (20 rows)
    
####Query 2
                                                              QUERY PLAN                                                          
    ------------------------------------------------------------------------------------------------------------------------------
     Aggregate  (cost=7661.83..7661.84 rows=1 width=0) (actual time=67.949..67.949 rows=1 loops=1)
       Output: count(*)
       Buffers: shared hit=2589
       ->  Nested Loop  (cost=0.00..7661.44 rows=154 width=0) (actual time=1.426..67.891 rows=142 loops=1)
             Buffers: shared hit=2589
             ->  Seq Scan on public.people p  (cost=0.00..52.75 rows=1 width=4) (actual time=0.117..0.403 rows=1 loops=1)
                   Output: p.id, p.name, p.gender, p.height
                   Filter: (p.id = 1299)
                   Rows Removed by Filter: 2539
                   Buffers: shared hit=21
             ->  Seq Scan on public.results r  (cost=0.00..7607.15 rows=154 width=4) (actual time=1.306..67.384 rows=142 loops=1)
                   Output: r.peopleid, r.competitionid, r.sportid, r.result
                   Filter: (r.peopleid = 1299)
                   Rows Removed by Filter: 402990
                   Buffers: shared hit=2568
     Planning time: 0.147 ms
     Execution time: 68.006 ms
    (17 rows)

##Part II
| Command | Time            |
|---------|-----------------|
| FILL    | 00:00:49.418977 |

###Query results
####Query 1
                                                                      QUERY PLAN                                                                  
    ----------------------------------------------------------------------------------------------------------------------------------------------
     Aggregate  (cost=8619.61..8619.62 rows=1 width=0) (actual time=62.892..62.892 rows=1 loops=1)
       Output: count(*)
       Buffers: shared hit=2570 dirtied=1
       ->  Nested Loop  (cost=0.15..8418.75 rows=80344 width=0) (actual time=0.021..57.671 rows=80465 loops=1)
             Buffers: shared hit=2570 dirtied=1
             ->  Index Only Scan using sports_pkey on public.sports s  (cost=0.15..8.17 rows=1 width=4) (actual time=0.012..0.015 rows=1 loops=1)
                   Output: s.id
                   Index Cond: (s.id = 4)
                   Heap Fetches: 1
                   Buffers: shared hit=2 dirtied=1
             ->  Seq Scan on public.results r  (cost=0.00..7607.15 rows=80344 width=4) (actual time=0.008..49.792 rows=80465 loops=1)
                   Output: r.peopleid, r.competitionid, r.sportid, r.result
                   Filter: (r.sportid = 4)
                   Rows Removed by Filter: 322667
                   Buffers: shared hit=2568
     Planning time: 0.162 ms
     Execution time: 62.936 ms
    (17 rows)
    
####Query 2
                                                                      QUERY PLAN                                                                  
    ----------------------------------------------------------------------------------------------------------------------------------------------
     Aggregate  (cost=511.95..511.96 rows=1 width=0) (actual time=0.243..0.243 rows=1 loops=1)
       Output: count(*)
       Buffers: shared hit=145
       ->  Nested Loop  (cost=5.90..511.56 rows=155 width=0) (actual time=0.066..0.229 rows=142 loops=1)
             Buffers: shared hit=145
             ->  Index Only Scan using people_pkey on public.people p  (cost=0.28..8.30 rows=1 width=4) (actual time=0.016..0.016 rows=1 loops=1)
                   Output: p.id
                   Index Cond: (p.id = 1299)
                   Heap Fetches: 1
                   Buffers: shared hit=3
             ->  Bitmap Heap Scan on public.results r  (cost=5.62..501.71 rows=155 width=4) (actual time=0.048..0.198 rows=142 loops=1)
                   Output: r.peopleid, r.competitionid, r.sportid, r.result
                   Recheck Cond: (r.peopleid = 1299)
                   Heap Blocks: exact=139
                   Buffers: shared hit=142
                   ->  Bitmap Index Scan on results_pkey  (cost=0.00..5.58 rows=155 width=0) (actual time=0.029..0.029 rows=142 loops=1)
                         Index Cond: (r.peopleid = 1299)
                         Buffers: shared hit=3
     Planning time: 0.141 ms
     Execution time: 0.327 ms
    (20 rows)

##Part III
(a) We should be using result attribute along with the sportid attribute. The index should use the sportid attribute first and then result, thusly
    CREATE INDEX result_index ON Results(sportid,result);
    
(b) The above index returns results on SCALEDB within an "acceptable" timeframe when running Query 7. Without it Query 7 takes a very long time. Using Query 7 on Project 2 (database P2) without the index gives a result but with the index it's much faster.

| Database | Index? | Execution time |
|----------|--------|----------------|
| SCALEDB  | No     | N/A            |
| SCALEDB  | Yes    | 2544.877 ms    |
| P2       | No     | 13405.046 ms   |
| P2       | Yes    | 87.263 ms      |

(c) By comparing the Explain from the Query 7 without and with the index we can see that it uses the index.

####P2 No Index
                                                                                QUERY PLAN                                                                             
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
     HashAggregate  (cost=1981629.07..1981629.70 rows=51 width=166) (actual time=13404.888..13404.894 rows=41 loops=1)
       Output: p.id, p.name, p.height, r.result, s.name, (CASE (r.result = s.record) WHEN CASE_TEST_EXPR THEN 'Yes'::text ELSE 'No'::text END)
       Group Key: p.id, p.name, p.height, r.result, s.name, CASE (r.result = s.record) WHEN CASE_TEST_EXPR THEN 'Yes'::text ELSE 'No'::text END
       Buffers: shared hit=659104
       ->  Nested Loop  (cost=0.00..1981628.30 rows=51 width=166) (actual time=13402.342..13404.836 rows=59 loops=1)
             Output: p.id, p.name, p.height, r.result, s.name, CASE (r.result = s.record) WHEN CASE_TEST_EXPR THEN 'Yes'::text ELSE 'No'::text END
             Join Filter: (r.sportid = s.id)
             Rows Removed by Join Filter: 354
             Buffers: shared hit=659104
             ->  Seq Scan on public.sports s  (cost=0.00..15.10 rows=510 width=130) (actual time=0.002..0.005 rows=7 loops=1)
                   Output: s.id, s.name, s.record
                   Buffers: shared hit=1
             ->  Materialize  (cost=0.00..1981223.05 rows=51 width=44) (actual time=285.721..1914.961 rows=59 loops=7)
                   Output: p.id, p.name, p.height, r.result, r.sportid
                   Buffers: shared hit=659103
                   ->  Nested Loop  (cost=0.00..1981222.80 rows=51 width=44) (actual time=2000.037..13404.674 rows=59 loops=1)
                         Output: p.id, p.name, p.height, r.result, r.sportid
                         Join Filter: (p.id = r.peopleid)
                         Rows Removed by Join Filter: 14927
                         Buffers: shared hit=659103
                         ->  Seq Scan on public.people p  (cost=0.00..5.54 rows=254 width=32) (actual time=0.005..0.056 rows=254 loops=1)
                               Output: p.id, p.name, p.gender, p.height
                               Buffers: shared hit=3
                         ->  Materialize  (cost=0.00..1981023.07 rows=51 width=16) (actual time=0.007..52.767 rows=59 loops=254)
                               Output: r.result, r.peopleid, r.sportid
                               Buffers: shared hit=659100
                               ->  Seq Scan on public.results r  (cost=0.00..1981022.82 rows=51 width=16) (actual time=1.642..13402.012 rows=59 loops=1)
                                     Output: r.result, r.peopleid, r.sportid
                                     Filter: (r.result = (SubPlan 1))
                                     Rows Removed by Filter: 10080
                                     Buffers: shared hit=659100
                                     SubPlan 1
                                       ->  Aggregate  (cost=195.36..195.37 rows=1 width=8) (actual time=1.318..1.318 rows=1 loops=10139)
                                             Output: max(r1.result)
                                             Buffers: shared hit=659035
                                             ->  Seq Scan on public.results r1  (cost=0.00..191.74 rows=1448 width=8) (actual time=0.005..1.115 rows=2012 loops=10139)
                                                   Output: r1.peopleid, r1.competitionid, r1.sportid, r1.result
                                                   Filter: (r1.sportid = r.sportid)
                                                   Rows Removed by Filter: 8127
                                                   Buffers: shared hit=659035
     Planning time: 1.134 ms
     Execution time: 13405.046 ms
    (42 rows)
    
####P2 With Index
                                                                                              QUERY PLAN                                                                                           
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     HashAggregate  (cost=5441.82..5442.46 rows=51 width=166) (actual time=87.207..87.215 rows=41 loops=1)
       Output: p.id, p.name, p.height, r.result, s.name, (CASE (r.result = s.record) WHEN CASE_TEST_EXPR THEN 'Yes'::text ELSE 'No'::text END)
       Group Key: p.id, p.name, p.height, r.result, s.name, CASE (r.result = s.record) WHEN CASE_TEST_EXPR THEN 'Yes'::text ELSE 'No'::text END
       Buffers: shared hit=30712 read=6
       ->  Nested Loop  (cost=0.29..5441.06 rows=51 width=166) (actual time=0.078..87.037 rows=59 loops=1)
             Output: p.id, p.name, p.height, r.result, s.name, CASE (r.result = s.record) WHEN CASE_TEST_EXPR THEN 'Yes'::text ELSE 'No'::text END
             Buffers: shared hit=30712 read=6
             ->  Nested Loop  (cost=0.14..5383.88 rows=51 width=44) (actual time=0.068..86.779 rows=59 loops=1)
                   Output: p.id, p.name, p.height, r.result, r.sportid
                   Buffers: shared hit=30594 read=6
                   ->  Seq Scan on public.results r  (cost=0.00..5354.95 rows=51 width=16) (actual time=0.063..86.514 rows=59 loops=1)
                         Output: r.peopleid, r.competitionid, r.sportid, r.result
                         Filter: (r.result = (SubPlan 2))
                         Rows Removed by Filter: 10080
                         Buffers: shared hit=30476 read=6
                         SubPlan 2
                           ->  Result  (cost=0.50..0.51 rows=1 width=0) (actual time=0.008..0.008 rows=1 loops=10139)
                                 Output: $1
                                 Buffers: shared hit=30411 read=6
                                 InitPlan 1 (returns $1)
                                   ->  Limit  (cost=0.29..0.50 rows=1 width=8) (actual time=0.007..0.007 rows=1 loops=10139)
                                         Output: r1.result
                                         Buffers: shared hit=30411 read=6
                                         ->  Index Only Scan Backward using result_index on public.results r1  (cost=0.29..307.72 rows=1435 width=8) (actual time=0.007..0.007 rows=1 loops=10139)
                                               Output: r1.result
                                               Index Cond: ((r1.sportid = r.sportid) AND (r1.result IS NOT NULL))
                                               Heap Fetches: 10139
                                               Buffers: shared hit=30411 read=6
                   ->  Index Scan using people_pkey on public.people p  (cost=0.14..0.56 rows=1 width=32) (actual time=0.003..0.003 rows=1 loops=59)
                         Output: p.id, p.name, p.gender, p.height
                         Index Cond: (p.id = r.peopleid)
                         Buffers: shared hit=118
             ->  Index Scan using sports_pkey on public.sports s  (cost=0.15..1.11 rows=1 width=130) (actual time=0.002..0.002 rows=1 loops=59)
                   Output: s.id, s.name, s.record
                   Index Cond: (s.id = r.sportid)
                   Buffers: shared hit=118
     Planning time: 0.515 ms
     Execution time: 87.263 ms
    (38 rows)
