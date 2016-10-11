/**********************************************
 * Assignment 8: Database Design
 * by
 * Hreiðar Ólafur Arnarsson, hreidara14@ru.is
 * 
 **********************************************/

/* TASK 1 */
/* Information about all the players in the club:
 * - ID
 * - name
 * - gender
 * - salary
 * - biography
 */
 
/* TASK 2 */
/* Information about coaches:
 * - ID
 * - name
 * - salary
 * - name of coaching degree
 * - date of issue for coaching degree
 * Coach can train more than on team. Each team can have more than on coach.
 * Salary of coaches is registered specifically for each team trained.
 */
 
/* TASK 3 */
/* Information about teams:
 * - Team nickname (unique)
 * - gender of players
 * - year of foundation
 * Each player can only be registered for one team. Each team has many players.
 * Team is always registered for some division.
 */

/* TASK 4 */
/* Information about divisions:
 * - name of the division
 * - gender of teams
 * - sponsors
 * Each division has many teams but each team can only play in one division.
 * A single women's division can have the same name as a single men's division.
 * But divisions of same gender have unique names.
 */

/* TASK 5 */
/* Information about matches:
 * - the team
 * - date
 * - time
 * - venue
 * - opponent
 * - score
 * Each team can only play one match at the same date and time.
 */
 
