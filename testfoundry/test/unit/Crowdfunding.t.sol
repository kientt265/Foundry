pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
contract CrowdfundingTest is Test {
    uint256 number;
    Crowdfunding public crowfunding;
    address public constant USER  = address(1); //tạo user để test
    address public ethPriceFeed;
    uint256 public constant INITIAL_USER_BALANCE = 100 ether;
    uint256 public constant USER_AMOUNT_FUNDING = 5 ether;
    uint8 public constant PRICE_FEED_DECIMALS = 8;
    int256 public constant ETH_USD_INITIAL_PRICE = 3000e8;

    event Funded(address indexed funder, uint256 value);

    function setUp() external {
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(PRICE_FEED_DECIMALS, ETH_USD_INITIAL_PRICE );
        ethPriceFeed = address(mockV3Aggregator);
        crowfunding = new Crowdfunding(ethPriceFeed);

        vm.deal(USER, INITIAL_USER_BALANCE);//thêm tiền vào cho user

    }

    function test_Setup() public  view{
        console.log(address(crowfunding));
    }
    function test_revert_fund() public {
        //revert if user not pay eunough
        vm.expectRevert("No available amount !");
        vm.prank(USER);
        crowfunding.fund();
    }
    function test_getPriceFeedVersion() public view {
        uint256 version = crowfunding.getPriceFeedVersion();
        console.log("pricefeed version");
        assertEq(version, 4);
    }
    function test_getEthUsdPrice() view public {
        uint256 ethUsdPrice = crowfunding.getEthUsdPrice();
        assertEq(uint(ETH_USD_INITIAL_PRICE)*1e10 , ethUsdPrice);
    }
    function test_can_fund() public {
        uint256 beforeuserBal = USER.balance; //kiem tra tien cua user
        uint beforeContractBal = address(crowfunding).balance;
        // vm.expectEmit();
        // emit Crowdfunding.Funded(USER, USER_AMOUNT_FUNDING);
        vm.prank(USER); //user dc goi vao fund()
        console.log("Before User Balance", beforeuserBal);
        crowfunding.fund{value: USER_AMOUNT_FUNDING}();
        uint afterContractBal = address(crowfunding).balance;
        uint afterUserBal = USER.balance;
        console.log("Afters User Bal", afterUserBal);
        assertEq(beforeuserBal - USER_AMOUNT_FUNDING, afterUserBal); //test
        assertEq(beforeContractBal + USER_AMOUNT_FUNDING, afterContractBal);
        assertEq(crowfunding.s_funderToAmount(USER), USER_AMOUNT_FUNDING); 
        assertTrue(crowfunding.s_isFunders(USER));
        assertEq(crowfunding.s_funders(0), USER );
        assertEq(crowfunding.getFundersLength(), 1);
    }
}
