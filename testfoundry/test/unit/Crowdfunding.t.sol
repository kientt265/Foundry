pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
contract CrowdfundingTest is Test {
    uint256 number;
    Crowdfunding public crowfunding;
    address public constant USER  = address(1); //tạo user để test
    uint256 public constant INITIAL_USER_BALANCE = 100 ether;
    uint256 public constant USER_AMOUNT_FUNDING = 5 ether;
    function setUp() external {
        crowfunding = new Crowdfunding();
        vm.deal(USER, INITIAL_USER_BALANCE);//thêm tiền vào cho user
    }

    function test_Setup() public  view{
        console.log(address(crowfunding));
    }
    function test_can_fund() public {
        uint256 beforeuserBal = USER.balance; //kiem tra tien cua user
        uint beforeContractBal = address(crowfunding).balance;
        console.log("Before User Balance", beforeuserBal);
        vm.prank(USER); //user dc goi vao fund
        crowfunding.fund{value: USER_AMOUNT_FUNDING}();
        uint afterContractBal = address(crowfunding).balance;
        uint afterUserBal = USER.balance;
        console.log("Afters User Bal", afterUserBal);
        assertEq(beforeuserBal - USER_AMOUNT_FUNDING, afterUserBal); //test
        assertEq(beforeContractBal + USER_AMOUNT_FUNDING, afterContractBal);
        assertEq(crowfunding, s_funderToAmount(USER), );
    }
}
